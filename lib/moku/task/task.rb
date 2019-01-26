# frozen_string_literal: true

require "moku/status"

module Moku
  module Task

    # A single conceptual step in a plan. Tasks primarily achieve their
    # results through side effects.
    class Task
      # @param target [Artifact,Release]
      # @return [Status]
      def call(target) # rubocop:disable Lint/UnusedMethodArgument
        Status.success
      end

      def to_s
        @to_s ||= self.class.to_s.split("::").last
      end
    end

  end
end
