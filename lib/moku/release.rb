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
    def initialize(artifact:, deploy_config:, remote_runner: nil, user: nil)
      @artifact = artifact
      @deploy_config = deploy_config
      @remote_runner = remote_runner || Moku.remote_runner
      @user = user || Moku.user
      @id = Time.now.strftime(Moku.release_time_format)
    end

    attr_reader :id

    def path
      artifact.path
    end

    def deploy_path
      deploy_config.deploy_dir/"releases"/id
    end

    def app_path
      deploy_config.deploy_dir/"current"
    end

    def systemd_services
      deploy_config.systemd_services
    end

    def run(scope, command)
      run_on_hosts(
        scope.apply(deploy_config.sites),
        command
      )
    end

    private

    attr_reader :artifact, :deploy_config, :remote_runner, :user

    def run_on_hosts(hosts, command)
      Sequence.for(hosts) do |host|
        remote_runner.run(
          user: user,
          host: host.hostname,
          command: contextualize(command)
        )
      end
    end

    def contextualize(command)
      "if [ -d #{deploy_path} ]; " \
        "then cd #{deploy_path}; " \
        "fi; " \
        "#{deploy_config.shell_env} #{command}"
    end

  end
end
