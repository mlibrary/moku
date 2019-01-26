# frozen_string_literal: true

require "moku/filesystem"
require "moku/scm/working_directory"
require "moku/scm/git/local_resolver"
require "moku/scm/git/remote_resolver"
require "pathname"

module Moku
  module SCM

    # Wraps git commands
    class Git
      # @param system_runner
      # @param filesystem [Filesystem]
      # @param local_resolver [LocalGitResolver]
      # @param remote_resolver [RemoteGitResolver]
      def initialize(system_runner:, filesystem:, local_resolver: nil, remote_resolver: nil)
        @system_runner = system_runner
        @filesystem = filesystem
        @local_resolver = local_resolver || LocalResolver.new(system_runner)
        @remote_resolver = remote_resolver || RemoteResolver.new(system_runner)
      end

      # @param uri [String]
      # @param commitish [String]
      # @return [String]
      def sha(uri, commitish)
        if filesystem.exists?(Pathname.new(uri))
          local_resolver.sha(uri, commitish)
        else
          remote_resolver.sha(uri, commitish)
        end
      end

      # Checkout into the given directory, and return the files. The
      # block form will additionally yield the files.
      # @param dir [Pathname] A path to an existing, empty directory
      # @yield [Array<Pathname>] Files contained in the
      #   checked-out repository, including the working directory
      #   itself.
      # @return [WorkingDirectory]
      def safe_checkout(url, commitish, dir)
        cloned_dir = Pathname.new(dir)
        system_runner.run("git clone #{url} #{cloned_dir}")
        working_directory = filesystem.chdir(cloned_dir) do
          system_runner.run("git checkout #{commitish}")
          build_working_dir(cloned_dir)
        end
        yield working_directory if block_given?
        working_directory
      end

      private

      attr_reader :system_runner, :filesystem
      attr_reader :remote_resolver, :local_resolver

      def build_working_dir(dir)
        files = filesystem.chdir(dir) do
          stdout = system_runner.run("git ls-files").output
          stdout
            .split("\n")
            .map {|file| Pathname.new(file) }
        end
        WorkingDirectory.new(dir, files)
      end
    end
  end

end
