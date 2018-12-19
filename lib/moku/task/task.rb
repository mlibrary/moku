# frozen_string_literal: true

require "moku/status"

module Moku
  module Task

    # A single conceptual step in a plan. Tasks primarily achieve their
    # results through side effects.
    class Task
      # @param target [Artifact,Release]
      # @return [Status]
      def call(target)
        Status.success
      end

      def to_s
        self.class.to_s
      end

      protected

      # Evaluate some block in the context of the path, shedding
      # our own bundler context.
      def with_env(path)
        Bundler.with_clean_env do
          Dir.chdir(path) do
            yield
          end
        end
      end
    end

  end
end
