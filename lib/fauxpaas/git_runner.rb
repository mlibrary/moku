require "fauxpaas/open3_capture"
require "pathname"

module Fauxpaas
  class GitRunner
    class UnknownReferenceError < RuntimeError; end

    def initialize(system_runner = Open3Capture.new)
      @system_runner = system_runner
    end

    # Checkout into a temporary directory, and yield the dir
    def safe_checkout(url, commitish, &block)
      Dir.mktmpdir do |dir|
        system_runner.run("git clone #{url} #{dir}")
        Dir.chdir(dir) do
          system_runner.run("git checkout #{commitish}")
          yield Pathname.new(dir)
        end
      end
    end

    private
    attr_reader :system_runner
  end
end
