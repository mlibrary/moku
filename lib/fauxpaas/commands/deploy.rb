# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"
require "fauxpaas/commands/restart"

module Fauxpaas

  module Commands
    # Create and deploy a release
    class Deploy < Command
      def initialize(instance_name:, user:, reference: nil)
        super(instance_name: instance_name, user: user)
        @reference = reference
      end

      def action
        :deploy
      end

      def execute
        signature = instance.signature(reference)

        release = Release.new(
          artifact: Fauxpaas.artifact_builder.build(signature),
          deploy_config: DeployConfig.from_ref(signature.deploy, Fauxpaas.ref_repo)
        )
        status = release.deploy
        report(status, action: "deploy")

        if status.success?
          instance.log_release(LoggedRelease.new(user, Time.now, signature))
          Fauxpaas.instance_repo.save_releases(instance)
          Fauxpaas.invoker.add_command(
            Restart.new(instance_name: instance_name, user: user)
          )
        end
      end

      private

      def reference
        @reference || instance.default_branch
      end
    end

  end
end
