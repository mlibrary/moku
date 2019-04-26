# frozen_string_literal: true

require "open3"
require "moku/status"

module Moku
  module Shell

    # A basic shell
    class Basic

      # Run the given command
      # @param command [String] The command to run
      # @param message [String] Optional message to be displayed. When this is not provided,
      #   the full command is displayed.
      # @return [Status]
      def run(command, message = nil)
        Moku.logger.debug(message || command)
        Bundler.with_clean_env do
          stdout, stderr, status = Open3.capture3(command)
          Status.new(status.success?, stdout, stderr)
        end
      end
    end

  end
end
