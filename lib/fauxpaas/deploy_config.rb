module Fauxpaas
  class DeployConfig
    def initialize(deployer_env:, deploy_dir:, rails_env:, assets_prefix:)
      @deployer_env = deployer_env
      @deploy_dir = deploy_dir
      @rails_env = rails_env
      @assets_prefix = assets_prefix
    end

    attr_reader :deployer_env, :deploy_dir, :rails_env, :assets_prefix


  end
end
