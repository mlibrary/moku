# frozen_string_literal: true

require "moku/deploy_config"
require "moku/logged_release"
require "moku/pipeline/pipeline"
require "moku/plan/basic_build"
require "moku/plan/basic_deploy"
require "moku/plan/restart"
require "moku/release"
require "moku/sequence"
require "moku/sites/scope"
require "pathname"

module Moku
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

      attr_reader :reference, :signature, :artifact, :release

      def init
        @reference = command.reference
      end

      def construct_signature
        @signature = instance.signature(reference)
      end

      def build_artifact
        @artifact = Moku.artifact_repo.for(signature, Plan::BasicBuild)
      end

      def deploy_release
        @release = Release.new(
          artifact: artifact,
          deploy_config: DeployConfig.from_ref(signature.deploy, Moku.ref_repo)
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
        Moku.instance_repo.save_releases(instance)
      end

      def restart
        Plan::Restart.new(release).call
      end

      def cleanup_caches
        Sequence.for(instance.releases - instance.caches) do |logged_release|
          release.run(
            Sites::Scope.all,
            "rm -rf #{release.deploy_config.deploy_dir/logged_release.id}"
          )
        end
      end

    end
  end
end
