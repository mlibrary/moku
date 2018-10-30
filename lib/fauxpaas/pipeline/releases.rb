# frozen_string_literal: true

require "fauxpaas/pipeline/pipeline"
require "fauxpaas/logged_releases"

module Fauxpaas
  module Pipeline

    # Print the release history
    class Releases < Pipeline
      def call
        # Avoid calling step because the logger will be used for output,
        # and calling step would make it less clean.
        print_releases
      end

      private

      def long
        command.long
      end

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
