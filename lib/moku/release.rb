# frozen_string_literal: true

module Moku

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release
    extend Forwardable

    # @param artifact [Artifact]
    # @param deploy_config [DeployConfig]
    def initialize(artifact:, deploy_config:, release_dir: nil)
      @artifact = artifact
      @deploy_config = deploy_config
      @id = Time.now.strftime(Moku.release_time_format)
      @release_dir = release_dir || id
    end

    attr_reader :id
    def_delegators :@artifact, :path
    def_delegators :@deploy_config, :systemd_services, :sites, :env

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
      Moku.remote_context.for(self).run(scope, command)
    end

    private

    attr_reader :artifact, :deploy_config, :release_dir

  end
end
