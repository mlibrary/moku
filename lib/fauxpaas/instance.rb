require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance
    def initialize(name:, deployer_env:)
      @app, @stage = name.split("-")
      @deployer_env = deployer_env
    end

    attr_reader :app, :stage, :deployer_env

    def name
      "#{app}-#{stage}"
    end

    def eql?(other)
      name == other.name &&
        deployer_env == other.deployer_env
    end
    alias_method :==, :eql?


  end

end
