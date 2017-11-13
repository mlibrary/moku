# frozen_string_literal: true

module Fauxpaas

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release

    # @param deploy_config [DeployConfig]
    # @param infrastructure [Infrastructure]
    # @param Source [SourceReference]
    def initialize(deploy_config:, infrastructure:, source:)
      @deploy_config = deploy_config
      @infrastructure = infrastructure
      @source = source
    end

    attr_reader :deploy_config, :infrastructure, :source

    def deploy
      deploy_config
        .runner
        .deploy(infrastructure, source)
    end

    def eql?(other)
      source == other.source &&
        deploy_config == other.deploy_config &&
        infrastructure == other.infrastructure
    end

  end
end
