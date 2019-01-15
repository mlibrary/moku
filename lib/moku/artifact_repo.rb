# frozen_string_literal: true

require "moku/artifact"
require "pathname"
require "fileutils"

module Moku

  # Repository for built artifacts
  class ArtifactRepo

    # @param dir [Pathname] A directory in which to store artifacts
    def initialize(dir, max_cache: Moku.build_cache_max)
      @dir = Pathname.new(dir).tap(&:mkpath)
      @max_cache = (max_cache - 1) || 1
      # -1 because we prune before building, so we won't reach it until max + 1.
    end

    # Obtain the build for the given instance and signature, and build
    # it using the given plan if it is not already built.
    # This operation is idempotent.
    #
    # Any errors raised in the build process are re-raised. Artifacts
    # that fail to build successfully are purged.
    #
    # @param signature [ReleaseSignature]
    # @param plan [Class] The class, which should be Plan::Plan
    # @return [Artifact] The built artifact
    def for(signature, plan)
      cleanup!

      artifact = artifact_for(signature)
      unless artifact.path.exist?
        artifact.path.mkpath
        plan.new(artifact).call
      end

      artifact
    rescue StandardError
      FileUtils.remove_entry_secure(artifact.path)
      raise
    end

    private

    attr_reader :dir, :max_cache

    def cleanup!
      cached_dirs
        .sort_by(&:mtime)
        .slice(0, [0, cached_dirs.count - max_cache].max)
        .each {|cache| FileUtils.remove_entry_secure(cache) }
    end

    def cached_dirs
      dir.children.select(&:directory?)
    end

    def artifact_for(signature)
      Artifact.new(
        path: path_for(signature),
        signature: signature
      )
    end

    def dir_for(signature)
      [:source, :shared, :unshared]
        .map {|method| signature.public_send(method) }
        .map(&:commitish)
        .map {|sha| sha.slice(0, 7) }
        .join("-")
    end

    def path_for(signature)
      dir/dir_for(signature)
    end

  end

end
