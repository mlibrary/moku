# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/deploy_config"
require "fauxpaas/logged_release"
require "fauxpaas/command/command"
require "fauxpaas/plan/basic_build"
require "fauxpaas/plan/basic_deploy"
require "fauxpaas/plan/restart"

module Fauxpaas

  module Command
    # Create and deploy a release
    class Deploy < Command
      def initialize(instance_name:, user:, reference: nil)
        super(instance_name: instance_name, user: user)
        @reference = reference
      end

      def action
        :deploy
      end

      def artifact
        artifact = Artifact.new(
          path: Pathname.new(Dir.mktmpdir),
          signature: instance.signature(reference)
        )
        Plan::BasicBuild.new(artifact).call
        artifact
      end

      def execute
        signature = instance.signature(reference)

        release = Release.new(
          artifact: artifact,
          deploy_config: DeployConfig.from_ref(signature.deploy, Fauxpaas.ref_repo)
        )

        status = Plan::BasicDeploy.new(release).call
        report(status, action: "deploy")

        if status.success?
          instance.log_release(LoggedRelease.new(user, Time.now, signature))
          Fauxpaas.instance_repo.save_releases(instance)
          Plan::Restart.new(release).call
        end
      end

      private

      def reference
        @reference || instance.default_branch
      end
    end

  end
end
