# frozen_string_literal: true

module Fauxpaas

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release

    # @param deploy_config [DeployConfig]
    # @param built_release [BuiltRelease]
    def initialize(deploy_config:, artifact:)
      @deploy_config = deploy_config
      @artifact = artifact
    end

    def deploy
      deploy_config
        .runner
        .deploy(artifact)
    end

    def eql?(other)
      [:@artifact, :@deploy_config].index do |var|
        !instance_variable_get(var).eql?(other.instance_variable_get(var))
      end.nil?
    end

    private

    attr_reader :artifact
    attr_reader :deploy_config

  end
end
