# frozen_string_literal: true

require "moku/deploy_config"
require "moku/pipeline/pipeline"
require "moku/release"
require "moku/task/remote_shell"

module Moku
  module Pipeline

    # Execute an arbitrary command
    class Exec < Pipeline

      def initialize(cmd:, scope:, release_id:, signature:)
        @cmd = cmd
        @scope = scope
        @release_id = release_id
        @signature = signature
      end

      def call
        step :run_command
      end

      private

      attr_reader :cmd, :scope, :release_id, :signature

      def release
        Release.new(
          artifact: nil,
          deploy_config: DeployConfig.from_ref(signature.deploy, Moku.ref_repo),
          release_dir: release_id
        )
      end

      def run_command
        Task::RemoteShell.new(
          command: cmd,
          scope: scope
        ).call(release)
      end
    end

  end
end
