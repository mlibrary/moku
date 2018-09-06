# frozen_string_literal: true

module Fauxpaas

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release

    # @param deploy_config [DeployConfig]
    # @param source_path [Pathname]
    # @param shared_path [Pathname]
    # @param unshared_path [Pathname]
    def initialize(deploy_config:, source_path:, shared_path:, unshared_path:)
      @deploy_config = deploy_config
      @source_path = source_path
      @shared_path = shared_path
      @unshared_path = unshared_path
    end

    def deploy
      deploy_config
        .runner
        .deploy(source_path, shared_path, unshared_path)
    end

    def eql?(other)
      [:@shared_path, :@unshared, :@source_path, :@deploy_config].index do |var|
        instance_variable_get(var) != other.instance_variable_get(var)
      end.nil?
    end

    private

    attr_reader :shared_path, :unshared_path, :source_path
    attr_reader :deploy_config

  end
end
