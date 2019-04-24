# frozen_string_literal: true

require "moku/sequence"
require "shellwords"

module Moku
  module Shell

    # A shell that executes remote commands for a release
    class RemoteRelease

      # Utility class to build RemoteRelease instances
      class Builder
        def initialize(remote_runner:)
          @remote_runner = remote_runner
        end

        def for(release)
          RemoteRelease.new(
            sites: release.sites,
            deploy_path: release.deploy_path,
            env: release.env,
            remote_runner: remote_runner
          )
        end

        private

        attr_reader :remote_runner
      end

      def initialize(sites:, deploy_path:, env:, remote_runner:)
        @sites = sites
        @deploy_path = deploy_path
        @env = env
        @remote_runner = remote_runner
      end

      def run(scope, command)
        run_on_hosts(scope.apply(sites), command)
      end

      private

      attr_reader :sites, :deploy_path, :env, :remote_runner

      def shell_env
        env.keep_if {|_key, value| value }
          .map {|key, value| "#{key.to_s.upcase}=#{Shellwords.escape(value)}" }
          .join(" ")
      end

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
          "#{rbenv_env} #{shell_env} #{command}"
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
end
