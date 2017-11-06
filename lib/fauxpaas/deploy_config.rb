require "active_support/core_ext/hash/keys"

module Fauxpaas
  class DeployConfig

    def self.from_hash(hash)
      new(hash.symbolize_keys)
    end

    def initialize(deployer_env:, deploy_dir:, rails_env:, assets_prefix:)
      @deployer_env = deployer_env
      @deploy_dir = deploy_dir
      @rails_env = rails_env
      @assets_prefix = assets_prefix
    end

    attr_reader :deployer_env, :deploy_dir, :rails_env, :assets_prefix

    def to_hash
      @hash ||= {
        deployer_env: deployer_env,
        deploy_dir: deploy_dir,
        rails_env: rails_env,
        assets_prefix: assets_prefix
      }.stringify_keys
    end

    def eql?(other)
      to_hash == other.to_hash
    end
    alias_method :==, :eql?


  end
end
