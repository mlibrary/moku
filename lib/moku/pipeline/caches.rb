# frozen_string_literal: true

require "moku/pipeline/pipeline"
require "moku/logged_releases"

module Moku
  module Pipeline

    # Retrieve and print the list of cached instances
    class Caches < Pipeline
      def call
        # Avoid calling step because the logger will be used for output,
        # and calling step would make it less clean.
        print_caches
      end

      private

      def long
        command.long
      end

      def print_caches
        string = if long
          LoggedReleases.new(instance.caches).to_s
        else
          LoggedReleases.new(instance.caches).to_short_s
        end

        Moku.logger.info "\n#{string}"
      end
    end

  end
end
