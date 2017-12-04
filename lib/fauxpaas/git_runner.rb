# frozen_string_literal: true

require "fauxpaas/filesystem"
require "pathname"
require "tmpdir"

module Fauxpaas

  # Wraps git commands
  class GitRunner
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

    def initialize(system_runner:, fs: Filesystem.new, local_resolver:, remote_resolver:)
      @system_runner = system_runner
      @fs = fs
      @local_resolver = local_resolver
      @remote_resolver = remote_resolver
    end

    def sha(uri, commitish)
      if fs.exists? uri
        local_resolver.sha(uri, commitish)
      else
        remote_resolver.sha(uri, commitish)
      end
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
