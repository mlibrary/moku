require "fauxpaas/open3_capture"

module Fauxpaas
  class VerboseSystemRunner
    def initialize(runner: Open3Capture.new)
      @runner = runner
    end

    def run(string)
      puts "Executing '#{string}'"
      runner.run(string).tap { |output| report(output) }
    end

    def report(output)
      stdout,stderr,status = output

      puts "Command STDOUT"
      puts stdout
      puts "Command STDERR"
      puts stderr
      puts "Command exited with status #{status}"
    end

    private

    attr_reader :runner
  end
end
