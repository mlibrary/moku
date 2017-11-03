require "fauxpaas/filesystem"
require "pathname"
require "yaml"

module Fauxpaas
  class Release

    # @param deploy_config [DeployConfig]
    # @param infrastructure [Infrastructure]
    # @param Source [SourceReference]
    def initialize(deploy_config:, infrastructure:, source:, fs: Filesystem.new)
      @deploy_config = deploy_config
      @infrastructure = infrastructure
      @source = source
      @fs = fs
    end

    attr_reader :deploy_config, :infrastructure, :source

    def deploy
      fs.mktmpdir do |dir|
        infrastructure_path = Pathname.new(dir) + "infrastructure.yml"
        fs.write(infrastructure_path, YAML.dump(infrastructure.to_hash))
        _, _, status = deploy_config.runner
          .run(deploy_config.appname, "deploy", deploy_options(infrastructure_path))
        status
      end
    end

    def eql?(other)
      source == other.source &&
        deploy_config == other.deploy_config &&
        infrastructure == other.infrastructure
    end

    private
    attr_reader :fs

    def deploy_options(infrastructure_path)
      deploy_config.to_hash
        .merge(infrastructure_config_path: infrastructure_path.to_s)
        .merge(branch: source.reference.to_s, source_repo: source.url)
    end
  end
end
