# frozen_string_literal: true

require "moku/deploy_config"
require "moku/pipeline/pipeline"
require "moku/release"
require "moku/task/set_current"

module Moku
  module Pipeline

    # Rollback to a previous, cached release
    class Rollback < Pipeline

      def initialize(cache:, instance:, user:)
        @cache = cache
        @instance = instance
        @user = user
      end

      def call
        step :retrieve_signature
        step :construct_release
        step :set_current
        step :log_release
        step :restart
        logger.info "Rollback successful!"
      end

      private

      attr_reader :cache, :instance, :user
      attr_reader :signature, :release

      def retrieve_signature
        @signature = cache.signature
      end

      def construct_release
        @release = Release.new(
          release_dir: cache.id,
          artifact: nil,
          deploy_config: DeployConfig.from_ref(signature.deploy, Moku.ref_repo)
        )
      end

      def set_current
        Task::SetCurrent.new.call(release)
      end

      def log_release
        instance.log_release(LoggedRelease.new(
          id: release.id,
          user: user,
          time: Time.now,
          signature: signature,
          version: "rollback -> #{cache.id}"
        ))
        Moku.instance_repo.save_releases(instance)
      end

      def restart
        Plan::Restart.new(release).call
      end

    end

  end
end
