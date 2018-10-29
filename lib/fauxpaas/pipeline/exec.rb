# frozen_string_literal: true

require "fauxpaas/deploy_config"
require "fauxpaas/pipeline/pipeline"
require "fauxpaas/release"
require "fauxpaas/task/remote_shell"

module Fauxpaas
  module Pipeline

    # Execute an arbitrary command
    class Exec < Pipeline

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
          deploy_config: DeployConfig.from_ref(signature.deploy, Fauxpaas.ref_repo)
        )
      end

      def set_current
        Task::RemoteShell.new(
          command: command.cmd,
          per: command.per
        ).call(release)
      end
    end

  end
end
