# frozen_string_literal: true

require "fauxpaas/lazy/directory"
require "fileutils"

module Fauxpaas

  # Responsible for downloading references and converting them to files.
  # Provides an anchor point for features such as reference caching.
  class ReferenceRepo

    # @param dir [Pathname] A directory in which to store
    #   intermediate artifacts.
    def initialize(dir, runner = Fauxpaas.git_runner)
      @dir = dir
      @runner = runner
    end

    # Download the given archive reference, unpack it,
    # and return the contents without metadata.
    # @param ref [ArchiveReference]
    # @return [Lazy::Directory]
    def resolve(ref)
      wd = checkout(ref, dir_for(ref))
      Lazy::Directory.for(
        wd.dir,
        wd.relative_files.map do |relative_path|
          wd.dir/relative_path
        end
      )
    end

    private

    attr_reader :dir, :runner

    # @yield [SCM::WorkingDirectory] The directory in which
    #   the content has been checked out.
    def checkout(ref, subdir)
      runner.safe_checkout(ref.url, ref.commitish, subdir)
    end

    # Create a place to store a downloaded ref
    def dir_for(ref)
      subdir = dir/unique_hash(ref)
      FileUtils.mkdir_p subdir
      subdir
    end

    def unique_hash(ref)
      "#{ref.url}#{ref.commitish}".hash.to_s
    end

  end
end
