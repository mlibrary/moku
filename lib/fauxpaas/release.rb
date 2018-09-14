# frozen_string_literal: true

require "fauxpaas/artifact"

module Fauxpaas

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release

    # @param signature [ReleaseSignature]
    def initialize(signature)
      @signature = signature
    end

    def deploy_config
      @deploy_config ||= DeployConfig.from_ref(signature.deploy, Fauxpaas.ref_repo)
    end

    def artifact
      @artifact ||= Fauxpaas.artifact_builder.build(signature)
    end

    def deploy
      deploy_config
        .runner
        .deploy(artifact)
    end

    private

    attr_reader :signature

  end
end
