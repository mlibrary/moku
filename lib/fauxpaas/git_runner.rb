# frozen_string_literal: true

require "fauxpaas/open3_capture"
require "fauxpaas/filesystem"
require "pathname"

module Fauxpaas

  # Wraps git commands
  class GitRunner
    class UnknownReferenceError < RuntimeError; end
    class WorkingDirectory < Pathname
      def initialize(path, system_runner, fs)
        super(path)
        @system_runner = system_runner
        @fs = fs
      end

      def files
        @files ||= fs.chdir(path) do
          stdout, _, _ = system_runner.run("git ls-files")
          stdout
            .split("\n")
            .map{|file| Pathname.new(file) }
        end
      end

      private
      attr_reader :path, :system_runner, :fs
    end

    def initialize(system_runner: Open3Capture.new, fs: Filesystem.new)
      @system_runner = system_runner
      @fs = fs
    end

    # Checkout into a temporary directory, and yield the dir
    def safe_checkout(url, commitish)
      fs.mktmpdir do |dir|
        cloned_dir = Pathname.new(dir) + "fauxpaas"
        system_runner.run("git clone #{url} #{cloned_dir}")
        fs.chdir(cloned_dir) do
          system_runner.run("git checkout #{commitish}")
          yield WorkingDirectory.new(cloned_dir, system_runner, fs)
        end
      end
    end

    private

    attr_reader :system_runner, :fs
  end
end
