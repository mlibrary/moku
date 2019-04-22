# frozen_string_literal: true

require "moku/deploy_config"
require "moku/pipeline/pipeline"
require "moku/release"
require "moku/task/remote_shell"

module Moku
  module Pipeline

    # Execute an arbitrary command
    class Exec < Pipeline
      register(self)

      def self.handles?(command)
        command.action == :exec
      end

      def call
        step :run_command
      end

      private

      def release
        Release.new(
          artifact: nil,
          deploy_config: DeployConfig.from_ref(command.signature.deploy, Moku.ref_repo),
          release_dir: command.release_id
        )
      end

      def run_command
        Task::RemoteShell.new(
          command: command.cmd,
          scope: command.scope
        ).call(release)
      end
    end

  end
end
