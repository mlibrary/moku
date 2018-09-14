# frozen_string_literal: true

require "fauxpaas"
require "tmpdir"
require "pathname"
require "open3"

module Fauxpaas

  RSpec.describe "integration tests", integration: true do
    describe "deploy" do
      RSpec.shared_context "deploy setup" do |instance_name|
        before(:all) do
          @root = Pathname.new(File.realpath(Dir.tmpdir))/"fauxpaas"/"sandbox"/instance_name
          `mkdir -p #{@root}`
          Fauxpaas.reset!
          Fauxpaas.initialize!
          Fauxpaas.config.tap do |config|
            config.register(:instance_root) do
              Pathname.new("spec/fixtures/integration/instances").expand_path(Fauxpaas.root)
            end
            config.register(:releases_root) do
              Pathname.new("spec/fixtures/integration/releases").expand_path(Fauxpaas.root)
            end
            config.register(:deployer_env_root) do
              Pathname.new("spec/fixtures/integration/capfiles").expand_path(Fauxpaas.root)
            end

            config.register(:project_root) { Pathname.new(__FILE__).parent.parent }
            config.register(:fixtures_path) {|c| c.project_root/"spec"/"fixtures"/"integration" }
            config.register(:git_runner) { FileRunner.new }

            if ENV["DEBUG"]
              config.register(:logger) { Logger.new(STDOUT, level: :debug) }
              config.register(:system_runner) { Fauxpaas::PassthroughRunner.new(STDOUT) }
            else
              config.register(:logger) { Logger.new(StringIO.new, level: :info) }
            end
          end
          Fauxpaas.invoker.add_command(
            Commands::Deploy.new(
              user: ENV["USER"],
              instance_name: instance_name,
              reference: nil
            )
          )
        end
        after(:all) do
          `rm -rf #{@root}`
          `git checkout -- spec/fixtures/integration/instances`
          `git checkout -- spec/fixtures/integration/releases`
        end
        let(:root) { @root }
        let(:current_dir) { root/"current" }
        let(:shared_dir) { root/"shared" }
      end

      # Expects
      # let(:gem) { some gem name }
      # let(:source) { some source file relative path }
      RSpec.shared_examples "a successful deploy" do
        it "the 'releases' dir exists" do
          expect((root/"releases").exist?).to be true
        end
        it "the 'current' dir exists" do
          expect(current_dir.exist?).to be true
        end
        it "installs unshared files" do
          expect(File.read(current_dir/"some"/"dev"/"file.txt")).to eql("with some dev contents\n")
        end
        it "installs shared files" do
          expect(File.read(current_dir/"some"/"shared"/"file.txt"))
            .to eql("with some shared contents\n")
        end
        it "bundles gems in ./vendor/bundle" do
          expect(File.read(current_dir/".bundle"/"config"))
            .to match(%r{^BUNDLE_PATH: "vendor/bundle"$})
        end
        it "freezes the gems" do
          expect(File.read(current_dir/".bundle"/"config"))
            .to match(%r{^BUNDLE_FROZEN: "true"$})
        end
        it "packages a cache in ./vendor/cache" do
          expect((current_dir/"vendor"/"cache").exist?).to be true
        end

        xdescribe "permissions" do
          it "releases 2775" do
            expect((root/"releases").stat.mode & 0o7777).to eql(0o2775)
          end
          it "releases/<release> 2775" do
            release_dir = (root/"releases").children.first
            expect(release_dir.stat.mode & 0o7777).to eql(0o2775)
          end
          it "current/public 2775" do
            expect((current_dir/"public").stat.mode & 0o7777).to eql(0o2775)
          end
          it "current/<some_unshared> 660" do
            file = current_dir/"some"/"dev"/"file.txt"
            expect(file.stat.mode & 0o777).to eql(0o660)
          end
          it "current/<some_shared_file> 660" do
            file = current_dir/"some"/"shared"/"file.txt"
            expect(file.stat.mode & 0o777).to eql(0o660)
          end
          it "current/public/<file> 664" do
            file = (current_dir/"public").children.find(&:file?)
            expect(file.stat.mode & 0o777).to eql(0o664)
          end
          it "shared 2775" do
            expect(shared_dir.stat.mode & 0o7777).to eql(0o2775)
          end
          it "shared/public 2775" do
            expect((shared_dir/"public").stat.mode & 0o7777).to eql(0o2775)
          end
          it "shared/public/<file> 664" do
            file = (shared_dir/"public").children.find(&:file?)
            expect(file.stat.mode & 0o777).to eql(0o664)
          end
          it "shared/log 2770" do
            dir = current_dir/"log"
            expect(dir.exist?).to be true
            expect(dir.directory?).to be true
            expect(dir.stat.mode & 0o7777).to eql(0o2770)
          end
          it "current/log is a symlink to shared/log" do
            dir = current_dir/"log"
            expect(dir.symlink?).to be true
            expect(dir.realpath).to eql(shared_dir/"log")
          end
        end

        it "runs finish_build commands" do
          expect((current_dir/"eureka_2.txt").exist?).to be true
          expect(File.read(current_dir/"eureka_1.txt")).to eql("eureka!\n")
        end
        it "installs the gems" do
          # The expect {}-to-output syntax didn't like this test
          Bundler.with_clean_env do
            Dir.chdir(current_dir) do
              expect(`bundle list`).to match(/#{gem}/)
            end
          end
        end
        it "installs the source files" do
          expect((current_dir/source).exist?)
            .to be true
        end
      end

      context "without rails" do
        include_context "deploy setup", "test-norails"
        let(:gem) { "pry" }
        let(:development_gem) { "faker" }
        let(:test_gem) { "rspec" }
        let(:source) { Pathname.new("some_source_file.txt") }

        include_examples "a successful deploy"

        it "doesn't install development gems" do
          Bundler.with_clean_env do
            Dir.chdir(current_dir) do
              expect(`bundle list`).not_to match(/#{development_gem}/)
            end
          end
        end

        it "doesn't install test gems" do
          Bundler.with_clean_env do
            Dir.chdir(current_dir) do
              expect(`bundle list`).not_to match(/#{test_gem}/)
            end
          end
        end
      end

      context "with rails" do
        include_context "deploy setup", "test-rails"
        let(:gem) { "rails" }
        let(:source) { Pathname.new("config/environment.rb") }

        include_examples "a successful deploy"

        it "shared/public/assets 2775" do
          expect((shared_dir/"public"/"assets").stat.mode & 0o7777).to eql(0o2775)
        end

        it "current/public/assets is a symlink to shared/public/assets" do
          dir = current_dir/"public"/"assets"
          expect(dir.symlink?).to be true
          expect(dir.realpath).to eql(shared_dir/"public"/"assets")
        end

        it "runs the migrations" do
          expect(`sqlite3 #{current_dir/"db"/"production.sqlite3"} ".schema posts"`.chomp)
            .to match(/CREATE TABLE (IF NOT EXISTS )?"posts"/)
          expect(`sqlite3 #{current_dir/"db"/"production.sqlite3"} ".schema things"`.chomp)
            .to match(/CREATE TABLE (IF NOT EXISTS )?"things"/)
        end

        it "installs a working project" do
          Bundler.with_clean_env do
            Dir.chdir(current_dir) do
              _, _, status = Open3.capture3(
                "bin/rails runner -e production 'Post.new.valid?'"
              )
              expect(status.success?).to be true
            end
          end
        end
      end
    end
  end
end
