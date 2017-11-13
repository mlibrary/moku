require "fauxpaas/open3_capture"
require "fauxpaas/filesystem"
require "pathname"

module Fauxpaas
  class GitRunner
    class UnknownReferenceError < RuntimeError; end

    def initialize(system_runner: Open3Capture.new, fs: Filesystem.new)
      @system_runner = system_runner
      @fs = fs
    end

    # Checkout into a temporary directory, and yield the dir
    def safe_checkout(url, commitish, &block)
      fs.mktmpdir do |dir|
        cloned_dir = Pathname.new(dir) + "fauxpaas"
        system_runner.run("git clone #{url} #{cloned_dir}")
        fs.chdir(cloned_dir) do
          system_runner.run("git checkout #{commitish}")
          yield cloned_dir
        end
      end
    end

    private
    attr_reader :system_runner, :fs
  end
end
