# frozen_string_literal: true

require "fauxpaas/deploy_config"
require "fauxpaas/pipeline/pipeline"
require "fauxpaas/release"
require "fauxpaas/task/set_current"

module Fauxpaas
  module Pipeline

    # Rollback to a previous, cached release
    class Rollback < Pipeline

      def call
        step :retrieve_signature
        step :construct_release
        step :set_current
      end

      private

      attr_reader :signature, :release

      def retrieve_signature
        @signature = command.cache.signature
      end

      def construct_release
        @release = Release.new(
          artifact: nil,
          deploy_config: DeployConfig.from_ref(signature.deploy, Fauxpaas.ref_repo)
        )
      end

      def set_current
        Task::SetCurrent.new.call(release)
      end
    end

  end
end
