# frozen_string_literal: true

require "moku/deploy_config"
require "moku/logged_release"
require "moku/pipeline/pipeline"
require "moku/plan/basic_build"
require "moku/plan/docker_build"
require "moku/plan/basic_deploy"
require "moku/plan/docker_deploy"
require "moku/plan/restart"
require "moku/release"
require "moku/sequence"
require "moku/sites/scope"
require "pathname"

module Moku
  module Pipeline

    # Build and deploy a release
    #
    # Currently, this only supports BasicBuild and BasicDeploy, and does not feature
    # a method for extending that. Most likely, this sort of extension would be
    # attached to the instance configuration itself in instance.yml. This pipeline
    # would then choose appropriate Plans from that data.
    class Deploy < Pipeline
      register(self)

      def self.handles?(command)
        command.action == :deploy
      end

      def call
        step :init
        step :construct_signature
        step :build_artifact
        step :deploy_release
        step :log_release
        step :restart unless instance.docker?
        step :cleanup_caches unless instance.docker?
        Moku.logger.info "Deploy successful!"
      end

      private

      attr_reader :reference, :signature, :artifact, :release

      def build_plan
        if instance.docker?
          Plan::DockerBuild
        else
          Plan::BasicBuild
        end
      end

      def deploy_plan
        if instance.docker?
          Plan::DockerDeploy
        else
          Plan::BasicDeploy
        end
      end

      def init
        @reference = command.reference
      end

      def construct_signature
        @signature = instance.signature(reference)
      end

      def build_artifact
        @artifact, status = Moku.artifact_repo.for(signature, build_plan)
        status
      end

      def deploy_release
        @release = Release.new(
          artifact: artifact,
          deploy_config: DeployConfig.from_ref(signature.deploy, Moku.ref_repo)
        )
        deploy_plan.new(release).call
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
        exclude_caches = instance.caches.map {|cache| "grep -v #{cache.id}" }.join(" | ")
        cmd = "cd #{release.releases_path} && " \
          "ls -1 #{release.releases_path} | #{exclude_caches} | xargs rm -rf"
        release.run(Sites::Scope.all, cmd)
      end

    end
  end
end
