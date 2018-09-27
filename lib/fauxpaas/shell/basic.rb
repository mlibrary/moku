# frozen_string_literal: true

require "open3"
require "fauxpaas/status"

module Fauxpaas
  module Shell

    # A basic shell
    class Basic

      # Run the given command
      # @return [Status]
      def run(command)
        Fauxpaas.logger.info(command)
        Bundler.with_clean_env do
          stdout, stderr, status = Open3.capture3(command)
          Status.new(status.success?, stdout, stderr)
        end
      end
    end

  end
end
