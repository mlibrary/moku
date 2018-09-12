# frozen_string_literal: true

module Fauxpaas

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release

    # @param artifact [Artifact]
    # @param deploy_config [DeployConfig]
    def initialize(artifact:, deploy_config:)
      @artifact = artifact
      @deploy_config = deploy_config
    end

    def deploy
      deploy_config
        .runner
        .deploy(artifact)
    end

    private

    attr_reader :artifact, :deploy_config

  end
end
