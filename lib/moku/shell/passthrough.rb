# frozen_string_literal: true

require "open3"

module Moku
  module Shell

    # A shell that prints combined standard output and error to the
    # given stream as the messages are received.
    class Passthrough

      # @param stream [IO]
      def initialize(stream)
        @stream = stream
      end

      # @return [Status]
      def run(command, interactive = false)
        Moku.logger.debug(command)
        Bundler.with_clean_env do
	  if interactive
	    exec(command)
	  else
	    run_command(command)
	  end
        end
      end

      private

      attr_reader :stream

      def run_command(command)
        output = []
        Open3.popen2e(command) do |_stdin, cmd_output, thread|
          while (line = cmd_output.gets)
            stream.puts line
            output << line
          end
          Status.new(thread.value.success?, output.join, output.join)
        end
      end
    end

  end
end
