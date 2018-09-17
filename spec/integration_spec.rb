# frozen_string_literal: true

require "fauxpaas"
require "tmpdir"
require "pathname"
require "open3"

module Fauxpaas

  RSpec.describe "integration tests", integration: true do
    describe "deploy" do
      # This requires the context built by 'deploy setup'
      RSpec.shared_context "run deploy" do |instance_name|
        before(:all) do
          Fauxpaas.invoker.add_command(
            Commands::Deploy.new(
              user: ENV["USER"],
              instance_name: instance_name,
              reference: nil
            )
          )
        end
      end

      RSpec.shared_context "deploy setup" do |instance_name|
        before(:all) do
          Fauxpaas.reset!
          Fauxpaas.initialize!
          Fauxpaas.config.tap do |config|
            # Locate fixtures and the test sandbox
            config.register(:project_root) { Pathname.new(__FILE__).parent.parent }
            config.register(:test_run_id) {|c| rand(999999).to_s }
            config.register(:test_run_root) {|c| c.project_root/"sandbox"/c.test_run_id}
            config.register(:fixtures_root) {|c| c.project_root/"spec"/"fixtures"/"integration" }
            config.register(:fixtures_path) {|c| c.fixtures_root } # delete me
            config.register(:deploy_root) {|c| c.test_run_root/"deploy"}
            config.register(:test_deploy_locator) {|c| c.project_root/"sandbox"/"test_deploy_root"}

            # Configure the application
            config.register(:instance_root) {|c| c.test_run_root/"instances"}
            config.register(:releases_root) {|c| c.test_run_root/"releases" }
            config.register(:deployer_env_root) {|c| c.test_run_root/"capfiles" }

            # Configure the logger
            config.register(:git_runner) { FileRunner.new }
            if ENV["DEBUG"]
              config.register(:logger) { Logger.new(STDOUT, level: :debug) }
              config.register(:system_runner) { Fauxpaas::PassthroughRunner.new(STDOUT) }
            else
              config.register(:logger) { Logger.new(StringIO.new, level: :info) }
            end
          end

          @fauxpaas = Fauxpaas.config
          FileUtils.mkdir_p Fauxpaas.deploy_root
          FileUtils.mkdir_p Fauxpaas.test_run_root
          FileUtils.copy_entry("#{Fauxpaas.fixtures_root}/.", Fauxpaas.test_run_root)

          # The integration capfiles use this file to find the deploy_root
          File.write(Fauxpaas.test_deploy_locator, Fauxpaas.deploy_root)

        end
        after(:all) do
          FileUtils.rm_rf @fauxpaas.test_run_root
          FileUtils.rm_rf @fauxpaas.deploy_root
          FileUtils.rm_rf @fauxpaas.ref_root
          FileUtils.rm @fauxpaas.test_deploy_locator
        end
        let(:root) { @fauxpaas.deploy_root }
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
        include_context "run deploy", "test-norails"
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
        include_context "run deploy", "test-rails"
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
