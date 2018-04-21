# frozen_string_literal: true

require "open3"

module Fauxpaas
  class PassthroughRunner
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def run(command)
      output = []
      Open3.popen2e(command) do |_stdin, cmd_output, thread|
        while line = cmd_output.gets
          stream.puts line
          output << line
        end
        [output.join, output.join, thread.value]
      end
    end

  end
end
