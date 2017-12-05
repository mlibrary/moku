# frozen_string_literal: true

module Fauxpaas

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release

    # @param deploy_config [DeployConfig]
    # @param infrastructure [Infrastructure]
    # @param source [GitReference]
    def initialize(deploy_config:, infrastructure:, source:)
      @deploy_config = deploy_config
      @infrastructure = infrastructure
      @source = source
    end

    def deploy
      deploy_config
        .runner
        .deploy(infrastructure, source)
    end

    def eql?(other)
     instance_variables.index do |var|
        instance_variable_get(var) != other.instance_variable_get(var)
      end.nil?
    end

    private
    attr_reader :deploy_config, :infrastructure, :source

  end
end
