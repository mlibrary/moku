# frozen_string_literal: true

require "fauxpaas/release_builder"
require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance

    # @param name [String] Of the format appname-stagename
    # @param source [ArchiveReference]
    # @param deploy [ArchiveReference]
    # @param shared [Array<ArchiveReference>]
    # @param unshared [Array<ArchiveReference>]
    # @param releases [Array<LoggedRelease>]
    def initialize(name:, source:, deploy:, shared: [], unshared: [], releases: [])
      @name = name
      @app, @stage = name.split("-")
      @source = source
      @deploy = deploy
      @shared = shared
      @unshared = unshared
      @releases = releases
    end

    attr_reader :name, :app, :stage
    attr_reader :source, :deploy
    attr_reader :shared, :unshared, :releases


    # @param commitish [String]
    # @return [ReleaseSignature]
    def signature(commitish = nil)
      ReleaseSignature.new(
        deploy: deploy.latest,
        source: source.at(commitish),
        shared: shared.map(&:latest),
        unshared: unshared.map(&:latest)
      )
    end

    # @return [Cap] A deployer
    def interrogator(fs = Filesystem.new)
      deploy_config(fs).runner
    end

    # @return [String]
    def default_branch
      source.commitish
    end

    # @param value [String]
    def default_branch=(value)
      @source = source.at(value)
    end

    # @param release [LoggedRelease]
    def log_release(release)
      releases << release
    end

    private

    def deploy_config(fs)
      @deploy_config ||= deploy.latest.checkout do |working_dir|
        contents = YAML.safe_load(fs.read(working_dir.dir/"deploy.yml"))
        DeployConfig.from_hash(contents)
      end
    end

  end

end
