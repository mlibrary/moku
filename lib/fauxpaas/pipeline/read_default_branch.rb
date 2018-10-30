# frozen_string_literal: true

require "fauxpaas/pipeline/pipeline"

module Fauxpaas
  module Pipeline

    # Read and print the default branch
    class ReadDefaultBranch < Pipeline
      def call
        # Avoid calling step because the logger will be used for output,
        # and calling step would make it less clean.
        print_default_branch
      end

      private

      def print_default_branch
        logger.info "Default branch: #{instance.default_branch}"
      end
    end

  end
end
