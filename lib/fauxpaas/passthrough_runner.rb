require "open3"

module Fauxpaas
  class PassthroughRunner
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def run(command)
      Open3.popen2e(command) do |stdin, output, thread|
        while line = output.gets do
          stream.puts line
        end
        exit_status = thread.value
      end
    end

  end
end
