# frozen_string_literal: true

require "moku/sequence"

module Moku

  # Moku's cache of gems for use with bundler
  class CachedBundle

    # @param path [Pathname] The path to this cache
    def initialize(path)
      @path = path
      @paths = {}
    end

    attr_reader :path

    # Use moku's cache of gems to install an artifact's bundle. Missing gems
    # will be downloaded from the configured gem source (e.g. rubygems), and
    # also added to this cache.
    # @param artifact [Artifact]
    # @return [Status]
    def install(artifact)
      Sequence.for([
        "rsync -r #{cache_path(artifact)}/. #{artifact.bundle_path}/",
        "bundle install --deployment '--without=development test'",
        "rsync -r #{artifact.bundle_path}/. #{cache_path(artifact)}/",
        "bundle clean"
      ]) {|command| artifact.run(command) }
    end

    private

    def cache_path(artifact)
      @paths[artifact.gem_version] ||= (path/"vendor"/"bundle"/"ruby"/artifact.gem_version)
        .tap(&:mkpath)
    end

  end

end
