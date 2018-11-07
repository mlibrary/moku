# frozen_string_literal: true

require_relative "spec_helper"
require "moku"
require "moku/scm/file"
require_relative "support/fake_remote_runner"
require "tmpdir"
require "pathname"
require "open3"

module Moku

  RSpec.describe "integration tests", integration: true do
    describe "deploy" do
      # This requires the context built by 'deploy setup'
      RSpec.shared_context "with deploy run" do |instance_name|
        before(:all) do # rubocop:disable RSpec/BeforeAfterAll
          Moku.invoker.add_command(
            Command::Deploy.new(
              user: ENV["USER"],
              instance_name: instance_name,
              reference: nil
            )
          )
        end
      end

      RSpec.shared_context "with deploy set up" do |_instance_name|
        before(:all) do # rubocop:disable RSpec/BeforeAfterAll
          Moku.reset!
          Moku.initialize!
          Moku.config.tap do |config|
            # Locate fixtures and the test sandbox
            config.register(:test_run_root) { Moku.root/"sandbox" }
            config.register(:fixtures_root) { Moku.root/"spec"/"fixtures"/"integration" }
            config.register(:fixtures_path, &:fixtures_root) # delete me
            config.register(:deploy_root) {|c| c.test_run_root/"deploy" }

            # Configure the application
            config.register(:user) { ENV["USER"] }
            config.register(:instance_root) {|c| c.test_run_root/"instances" }
            config.register(:releases_root) {|c| c.test_run_root/"releases" }
            config.register(:deployer_env_root) {|c| c.test_run_root/"capfiles" }

            # Configure the logger
            config.register(:git_runner) { SCM::File.new }
            config.register(:remote_runner) {|c| FakeRemoteRunner.new(c.system_runner) }
            if ENV["DEBUG"]
              config.register(:logger) { Logger.new(STDOUT, level: :debug) }
              config.register(:system_runner) { Shell::Passthrough.new(STDOUT) }
            else
              config.register(:logger) { Logger.new(StringIO.new, level: :info) }
            end
          end

          @moku = Moku.config
          FileUtils.mkdir_p Moku.deploy_root
          FileUtils.mkdir_p Moku.test_run_root
          FileUtils.copy_entry("#{Moku.fixtures_root}/.", Moku.test_run_root)
        end

        # rubocop:disable RSpec/InstanceVariable
        after(:all) do # rubocop:disable RSpec/BeforeAfterAll
          FileUtils.rm_rf @moku.test_run_root
          FileUtils.rm_rf @moku.deploy_root
          FileUtils.rm_rf @moku.ref_root
        end
        # rubocop:enable RSpec/InstanceVariable

        let(:root) { @moku.deploy_root } # rubocop:disable RSpec/InstanceVariable
        let(:current_dir) { root/"current" }
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
            .to match(/^BUNDLE_PATH: "vendor\/bundle"$/)
        end
        it "freezes the gems" do
          expect(File.read(current_dir/".bundle"/"config"))
            .to match(/^BUNDLE_FROZEN: "true"$/)
        end

        describe "permissions" do
          it "releases 2775" do
            expect(root/"releases").to have_permissions("2775")
          end
          it "releases/<release> 2775" do
            release_dir = (root/"releases").children.first
            expect(release_dir).to have_permissions("2775")
          end
          it "current/public 2775" do
            expect(current_dir/"public").to have_permissions("2775")
          end
          it "current/public/<file> 664" do
            file = (current_dir/"public").children.find(&:file?)
            expect(file).to have_permissions("664")
          end
          it "current/<some_unshared> 660" do
            file = current_dir/"some"/"dev"/"file.txt"
            expect(file).to have_permissions("660")
          end
          it "current/<some_shared_file> 660" do
            file = current_dir/"some"/"shared"/"file.txt"
            expect(file).to have_permissions("660")
          end
          it "current/log 2770" do
            dir = current_dir/"log"
            expect(dir.exist?).to be true
            expect(dir.directory?).to be true
            expect(dir).to have_permissions("2770")
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
        include_context "with deploy set up", "test-norails"
        include_context "with deploy run", "test-norails"
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
        include_context "with deploy set up", "test-rails"
        include_context "with deploy run", "test-rails"
        let(:gem) { "rails" }
        let(:source) { Pathname.new("config/environment.rb") }

        include_examples "a successful deploy"

        it "current/public/assets 2775" do
          expect(current_dir/"public"/"assets").to have_permissions("2775")
        end

        it "current/bin/rails 6770" do
          expect(current_dir/"bin"/"rails").to have_permissions("6770")
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
