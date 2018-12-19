require "moku/sequence"

module Moku

  # Moku's cache of gems for use with bundler
  class CachedBundle
    def initialize(path:, runner:)
      @path = path
      @runner = runner
    end

    attr_reader :path, :runner

    # Install the artifact's gems into a bundler cache for that artifact. This
    # uses this object's own cached gems to speed up this operation, and
    # subsequently updates its cache with any new gems.
    # @param artifact [Artifact]
    # @return [Status]
    def install(artifact)
      install_path = artifact.path/"vendor"/"bundle"
      install_path.mkpath
      path.mkpath
      artifact.with_env do
        Sequence.for([
          "rsync -r #{path}/. #{install_path}/",
          "bundle install --deployment '--without=development test'",
          "rsync -r #{install_path}/. #{path}/",
          "bundle clean"
        ]) {|command| runner.run(command) }
      end
    end
  end

end
