# frozen_string_literal: true

require "moku/pipeline/pipeline"
require "moku/logged_releases"

module Moku
  module Pipeline

    # Print the release history
    class Releases < Pipeline

      def initialize(instance:, long:)
        @instance = instance
        @long = long
      end

      def call
        # Avoid calling step because the logger will be used for output,
        # and calling step would make it less clean.
        print_releases
      end

      private

      attr_reader :instance, :long

      def print_releases
        string = if long
          LoggedReleases.new(instance.releases).to_s
        else
          LoggedReleases.new(instance.releases).to_short_s
        end

        logger.info "\n#{string}"
      end
    end

  end
end
