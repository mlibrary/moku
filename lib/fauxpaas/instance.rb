# frozen_string_literal: true

require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance
    extend Forwardable
    def initialize(name:, deploy_config:, source:, releases: [])
      @app, @stage = name.split("-")
      @deploy_config = deploy_config
      @source = source
      @releases = releases
    end

    def_delegators :@deploy_config, :deployer_env, :deploy_dir, :rails_env, :assets_prefix

    attr_reader :app, :stage, :releases

    def source_repo
      source.url
    end

    def default_branch
      source.default_branch
    end

    def default_branch=(value)
      source.default_branch = value
    end

    def name
      "#{app}-#{stage}"
    end

    def eql?(other)
      name == other.name &&
        deployer_env == other.deployer_env
    end
    alias_method :==, :eql?

    def log_release(release)
      releases << release
    end

    private
    attr_accessor :source

  end

end
