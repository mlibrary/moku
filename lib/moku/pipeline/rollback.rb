# frozen_string_literal: true

require "moku/deploy_config"
require "moku/pipeline/pipeline"
require "moku/release"
require "moku/task/set_current"

module Moku
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
          deploy_config: DeployConfig.from_ref(signature.deploy, Moku.ref_repo)
        )
      end

      def set_current
        Task::SetCurrent.new.call(release)
      end
    end

  end
end
