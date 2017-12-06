# frozen_string_literal: true

require "active_support/core_ext/hash/keys"
require "fauxpaas/components/paths"
require "fauxpaas/components/backend_runner"
require "fauxpaas/cap"

module Fauxpaas

  # The deploy configuration used in the deployment of the instance. I.e. _how_ the
  # instance gets deployed.
  class DeployConfig

    def self.from_hash(hash)
      new(hash.symbolize_keys)
    end

    def initialize(appname:, deployer_env:, deploy_dir:, rails_env:, assets_prefix:, systemd_services: [])
      @appname = appname
      @deployer_env = deployer_env
      @deploy_dir = deploy_dir
      @rails_env = rails_env
      @assets_prefix = assets_prefix
      @systemd_services = systemd_services
    end

    attr_reader :appname, :deployer_env, :deploy_dir, :rails_env, :assets_prefix, :systemd_services

    def runner
      Cap.new(
        to_hash.merge("deployer_env" => Fauxpaas.deployer_env_root + deployer_env),
        appname,
        Fauxpaas.backend_runner
      )
    end

    def to_hash
      @hash ||= {
        appname:          appname,
        deployer_env:     deployer_env,
        deploy_dir:       deploy_dir,
        rails_env:        rails_env,
        assets_prefix:    assets_prefix,
        systemd_services: systemd_services
      }.stringify_keys
    end

    def eql?(other)
      to_hash == other.to_hash
    end
    alias_method :==, :eql?

  end
end
