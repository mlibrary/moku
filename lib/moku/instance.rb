# frozen_string_literal: true

require "moku/release_signature"
require "moku/deploy_config"
require "pathname"

module Moku

  # Represents a named instance within moku, as opposed
  # to installed on destination servers.
  class Instance

    # @param name [String] Of the format appname-stagename
    # @param source [ArchiveReference]
    # @param deploy [ArchiveReference]
    # @param infrastructure [ArchiveReference]
    # @param dev [ArchiveReference]
    # @param releases [Array<LoggedRelease>]
    def initialize(name:, source:, deploy:, infrastructure:, dev:, releases: [])
      @name = name
      @source = source
      @deploy = deploy
      @infrastructure = infrastructure
      @dev = dev
      @releases = releases
    end

    attr_reader :name
    attr_reader :source, :deploy
    attr_reader :infrastructure, :dev

    # @param commitish [String]
    # @return [ReleaseSignature]
    def signature(commitish = nil)
      ReleaseSignature.new(
        deploy: deploy.latest,
        source: source.at(commitish),
        infrastructure: infrastructure.latest,
        dev: dev.latest
      )
    end

    # @return [String]
    def default_branch
      source.commitish
    end

    # @param name [String]
    def default_branch=(name)
      @source = source.branch(name)
    end

    # @param release [LoggedRelease]
    def log_release(release)
      @releases << release
    end

    # @return [Array<LoggedRelease>]
    def caches
      releases
        .slice(0, 5)
    end

    # @return [Array<LoggedRelease>]
    def releases
      @releases
        .sort_by(&:id)
        .reverse
    end

    # @return [Boolean]
    def docker?
      deploy_config.target_type == "docker"
    end

    def deploy_config
      @deploy_config ||= DeployConfig.from_ref(deploy.latest, Moku.ref_repo)
    end

  end

end
