# frozen_string_literal: true

require "moku/artifact"
require "moku/bundleable"
require "moku/sequence"

module Moku

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release
    extend Forwardable
    include Bundleable

    # @param artifact [Artifact]
    # @param deploy_config [DeployConfig]
    def initialize(artifact:, deploy_config:, remote_runner: nil, release_dir: nil)
      @artifact = artifact
      @deploy_config = deploy_config
      @remote_runner = remote_runner || Moku.remote_runner
      @id = Time.now.strftime(Moku.release_time_format)
      @release_dir = release_dir || id
    end

    attr_reader :id
    def_delegators :@artifact, :path
    def_delegators :@deploy_config, :systemd_services, :sites

    # Absolute path to the directory where all releases are stored
    def releases_path
      deploy_config.deploy_dir/"releases"
    end

    # Absolute path where this release will be deployed
    def deploy_path
      releases_path/release_dir
    end

    # Absolute, logical path to where the application lives
    def app_path
      deploy_config.deploy_dir/"current"
    end

    # Run a command on this release's hosts, after applying the given scope
    # @param scope [Sites::Scope]
    # @param command [String]
    def run(scope, command)
      run_on_hosts(
        scope.apply(deploy_config.sites),
        command
      )
    end

    private

    attr_reader :artifact, :deploy_config, :remote_runner, :release_dir

    # Environment manipulation necessary to adopt the rbenv version of the
    # source to be installed. This only has an effect in the test environment
    # and development enviroments.
    def rbenv_env
      "PATH=$RBENV_ROOT/versions/$(rbenv local)/bin:$PATH"
    end

    def contextualize(command)
      "if [ -d #{deploy_path} ]; " \
        "then cd #{deploy_path}; " \
        "fi; " \
        "#{rbenv_env} #{deploy_config.shell_env} #{command}"
    end

    def run_on_hosts(hosts, command)
      Sequence.for(hosts) do |host|
        remote_runner.run(
          user: host.user,
          host: host.hostname,
          command: contextualize(command)
        )
      end
    end

  end
end
