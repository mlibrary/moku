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
        step :retrieve_signature
        step :construct_release
        step :run_command
      end

      private

      attr_reader :signature, :release

      def retrieve_signature
        @signature = command.signature
      end

      def construct_release
        @release = Release.new(
          artifact: nil,
          deploy_config: DeployConfig.from_ref(signature.deploy, Moku.ref_repo)
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
