require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance
    def initialize(name:, deployer_env:, default_branch: "master", releases: [])
      @app, @stage = name.split("-")
      @deployer_env = deployer_env
      @default_branch = default_branch
      @releases = releases
    end

    attr_reader :app, :stage, :deployer_env, :default_branch, :releases
    attr_writer :default_branch

    def name
      "#{app}-#{stage}"
    end

    def eql?(other)
      name == other.name &&
        deployer_env == other.deployer_env
    end

    def log_release(release)
      releases << release
    end

    alias_method :==, :eql?


  end

end
