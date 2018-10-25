# frozen_string_literal: true

require "fauxpaas/artifact"
require "fauxpaas/deploy_config"
require "fauxpaas/logged_release"
require "fauxpaas/pipeline/pipeline"
require "fauxpaas/release"
require "fauxpaas/sequence"
require "fauxpaas/plan/basic_build"
require "fauxpaas/plan/basic_deploy"
require "fauxpaas/plan/restart"
require "pathname"

module Fauxpaas
  module Pipeline

    # Build and deploy a release
    class Deploy < Pipeline

      def call
        step :init
        step :construct_signature
        step :build_artifact
        step :deploy_release
        step :log_release
        step :restart
        step :cleanup_caches
      end

      private

      attr_reader :build_dir, :reference, :signature, :artifact, :release

      def init
        @build_dir = Pathname.new(Dir.mktmpdir)
        @reference = command.reference
      end

      def construct_signature
        @signature = instance.signature(reference)
      end

      def build_artifact
        @artifact = Artifact.new(path: build_dir, signature: signature)
        Plan::BasicBuild.new(artifact).call
      end

      def deploy_release
        @release = Release.new(
          artifact: artifact,
          deploy_config: DeployConfig.from_ref(signature.deploy, Fauxpaas.ref_repo)
        )
        Plan::BasicDeploy.new(release).call
      end

      def log_release
        instance.log_release(LoggedRelease.new(
          id: release.id,
          user: user,
          time: Time.now,
          signature: signature,
          version: reference
        ))
        Fauxpaas.instance_repo.save_releases(instance)
      end

      def restart
        Plan::Restart.new(release).call
      end

      def cleanup_caches
        Sequence.for(instance.releases - instance.caches) do |logged_release|
          release.run_per_host("rm -rf #{release.deploy_config.deploy_dir/logged_release.id}")
        end
      end

    end
  end
end
