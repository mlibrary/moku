# frozen_string_literal: true

require "moku/scm/file"
require "pathname"
require_relative "local_upload"
require_relative "fake_remote_runner"
require_relative "realistic_remote_runner"

module Moku

  # Create a sandbox environment to which we can deploy and perform
  # other operations.
  #
  # It creates several directories:
  # * sandbox - The root of our scratch area
  # * sandbox/deploy - The root where we'll create the directories that represent
  #   our target hosts. Each host will have its own directory here.
  #
  # The central config must then be modified to point to these directories.
  # * instance_root in sandbox/instances: The location of instance information,
  #   i.e. the root of the instance definition structure that will include the
  #   permissions.yml and instance.yml files.
  # * releases_root in sandbox/releases: The storage location for release histories.
  # * git_runner: We specify a SCM that simply copies files.
  # * remote_runner: We specify a remote runner that simply runs the command locally.
  #
  # The strategy then is to copy our fixtures into this sandbox directory, thereby
  # populating the instance_root and releases_root in the sandbox. To avoid long test
  # run times, we expect the actual operation to be performed in a before(:all) block,
  # leaving the tests to just make assertions on the side effects of the result.
  RSpec.shared_context "with a sandbox" do |_instance_name|
    before(:all) do
      Moku.reset!
      Moku.initialize!
      Moku.config.tap do |config|
        # Locate fixtures and the test sandbox
        config.register(:test_run_root) { Moku.root/"sandbox" }
        config.register(:fixtures_root) { Moku.root/"spec"/"fixtures"/"integration" }
        config.register(:deploy_root) {|c| c.test_run_root/"deploy" }
        config.register(:build_root) {|c| c.test_run_root/"builds" }

        # Configure the application
        config.register(:user) { ENV["USER"] }
        config.register(:instance_root) {|c| c.test_run_root/"instances" }
        config.register(:releases_root) {|c| c.test_run_root/"releases" }
        config.register(:git_runner) { SCM::File.new }
        config.register(:upload_factory) { LocalUpload }

        # Configure the logger
        if ENV["DEBUG"]
          config.register(:logger) { Logger.new(STDOUT, level: :debug) }
          config.register(:system_runner) { Shell::Passthrough.new(STDOUT) }
        else
          config.register(:logger) { Logger.new(StringIO.new, level: :info) }
        end

        # Configure the remote_runner
        if ENV["SSH"]
          config.register(:remote_runner) {|c| RealisticRemoteRunner.new(c.system_runner) }
        else
          config.register(:remote_runner) {|c| FakeRemoteRunner.new(c.system_runner) }
        end
      end

      @moku = Moku.config
      FileUtils.mkdir_p Moku.deploy_root
      FileUtils.mkdir_p Moku.test_run_root
      FileUtils.copy_entry("#{Moku.fixtures_root}/.", Moku.test_run_root)
    end

    # rubocop:disable RSpec/InstanceVariable
    after(:all) do
      FileUtils.rm_rf @moku.test_run_root
      FileUtils.rm_rf @moku.deploy_root
      FileUtils.rm_rf @moku.ref_root
    end
    # rubocop:enable RSpec/InstanceVariable

    let(:deploy_root) { @moku.deploy_root } # rubocop:disable RSpec/InstanceVariable
  end
end
