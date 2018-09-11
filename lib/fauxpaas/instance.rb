# frozen_string_literal: true

require "fauxpaas/release_builder"
require "fauxpaas/release_signature"
require "fauxpaas/deploy_config"
require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance

    # @param name [String] Of the format appname-stagename
    # @param source [ArchiveReference]
    # @param deploy [ArchiveReference]
    # @param shared [ArchiveReference]
    # @param unshared [ArchiveReference]
    # @param releases [Array<LoggedRelease>]
    def initialize(name:, source:, deploy:, shared:, unshared:, releases: [])
      @name = name
      @source = source
      @deploy = deploy
      @shared = shared
      @unshared = unshared
      @releases = releases
    end

    attr_reader :name
    attr_reader :source, :deploy
    attr_reader :shared, :unshared, :releases

    # @param commitish [String]
    # @return [ReleaseSignature]
    def signature(commitish = nil)
      ReleaseSignature.new(
        deploy: deploy.latest,
        source: source.at(commitish),
        shared: shared.latest,
        unshared: unshared.latest
      )
    end

    # @return [Cap] A deployer
    def interrogator(ref_repo = Fauxpaas.ref_repo)
      deploy_config(ref_repo).runner
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
      releases << release
    end

    private

    def deploy_config(ref_repo)
      @deploy_config ||= DeployConfig.from_ref(deploy.latest, ref_repo)
    end

  end

end
