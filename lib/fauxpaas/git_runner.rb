# frozen_string_literal: true

require "fauxpaas/filesystem"
require "fauxpaas/working_directory"
require "pathname"
require "tmpdir"

module Fauxpaas

  # Wraps git commands
  class GitRunner
    # @param system_runner
    # @param fs [Filesystem]
    # @param local_resolver [LocalGitResolver]
    # @param remote_resolver [RemoteGitResolver]
    def initialize(system_runner:, fs:, local_resolver:, remote_resolver:)
      @system_runner = system_runner
      @fs = fs
      @local_resolver = local_resolver
      @remote_resolver = remote_resolver
    end

    # @param uri [String]
    # @param commitish [String]
    # @return [String]
    def sha(uri, commitish)
      if fs.exists?(Pathname.new(uri))
        local_resolver.sha(uri, commitish)
      else
        remote_resolver.sha(uri, commitish)
      end
    end

    # Checkout into a temporary directory, and yield the files
    # @yield [Array<Pathname>] Files contained in the
    #   checked-out repository, including the working directory
    #   itself.
    def safe_checkout(url, commitish)
      fs.mktmpdir do |dir|
        cloned_dir = Pathname.new(dir) + "fauxpaas"
        system_runner.run("git clone #{url} #{cloned_dir}")
        fs.chdir(cloned_dir) do
          system_runner.run("git checkout #{commitish}")
          yield working_dir(cloned_dir)
        end
      end
    end

    private

    attr_reader :system_runner, :fs
    attr_reader :remote_resolver, :local_resolver

    def working_dir(dir)
      files = fs.chdir(dir) do
        stdout, = system_runner.run("git ls-files")
        stdout
          .split("\n")
          .map {|file| Pathname.new(file) }
      end
      WorkingDirectory.new(dir, files)
    end
  end
end
