module Fauxpaas
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
        .deploy(infrastructure, deploy_options)
    end


    def eql?(other)
      source == other.source &&
        deploy_config == other.deploy_config &&
        infrastructure == other.infrastructure
    end

    private

    def deploy_options
      deploy_config.to_hash
        .merge(branch: source.reference.to_s, source_repo: source.url)
    end
  end
end
