require "fauxpaas/open3_capture"
require "pathname"

module Fauxpaas
  class GitRunner
    def initialize(runner = Open3Capture.new)
      @runner = runner
    end

    def ls_remote(url, commitish)
      stdout, _, _ = runner.run("git ls-remote #{url} #{commitish}")
      stdout
        .strip
        .split("\n")
        .map {|line| line.split }
    end

    def rev_parse(commitish)
      stdout, _, _ = runner.run("git rev-parse #{commitish}")
      stdout.strip
    end

    # Checkout into a temporary directory, and yield the dir
    def safe_checkout(url, commitish, &block)
      Dir.mktmpdir do |dir|
        runner.run("git clone #{url} #{dir}")
        Dir.chdir(dir) do
          runner.run("git checkout #{commitish}")
          yield Pathname.new(dir)
        end
      end
    end

    private
    attr_reader :runner
  end
end
