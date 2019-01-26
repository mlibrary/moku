# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    # Retrieve and install the artifact's gems (as defined by its Gemfile)
    class Bundle < Task
      # @param runner A system runner
      def initialize(cached_bundle: Moku.cached_bundle)
        @cached_bundle = cached_bundle
      end

      # @param artifact [Artifact]
      # @return [Status]
      def call(artifact)
        cached_bundle.install(artifact)
      end

      private

      attr_reader :cached_bundle
    end

  end
end
