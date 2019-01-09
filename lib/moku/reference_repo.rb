# frozen_string_literal: true

require "moku/lazy/directory"
require "fileutils"

module Moku

  # Responsible for downloading references and converting them to files.
  # Provides an anchor point for features such as reference caching.
  class ReferenceRepo

    # @param dir [Pathname] A directory in which to store
    #   intermediate artifacts.
    def initialize(dir, runner = Moku.git_runner, max_cache: Moku.ref_cache_max)
      @dir = dir
      @runner = runner
      @max_cache = max_cache || 1
    end

    # Download the given archive reference, unpack it,
    # and return the contents without metadata.
    # @param ref [ArchiveReference]
    # @return [Lazy::Directory]
    def resolve(ref)
      wd = checkout(ref, dir_for(ref))
      cleanup!
      Lazy::Directory.for(
        wd.dir,
        wd.relative_files.map do |relative_path|
          wd.dir/relative_path
        end
      )
    end

    private

    attr_reader :dir, :runner, :max_cache

    def cached_references
      dir.children.select(&:directory?)
    end

    # Remove caches in excess of the amount allowed by max_cache,
    # starting with the oldest.
    def cleanup!
      cached_refs = cached_references
      cached_refs
        .sort_by(&:mtime)
        .slice(0, [0, cached_refs.count - max_cache].max)
        .each {|cache| FileUtils.remove_entry_secure(cache) }
    end

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
