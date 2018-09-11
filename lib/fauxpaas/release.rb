# frozen_string_literal: true

module Fauxpaas

  # Uniquely identifies a deployed instance at a point in time. All deployment
  # operations first create a release, and then attempt to deploy it.
  class Release

    # @param deploy_config [DeployConfig]
    # @param artifact [Artifact]
    def initialize(signature:, fs:,
      artifact_factory: Artifact,
      deploy_config_factory: DeployConfig)
      @artifact = artifact_factory.new(signature: signature, fs: fs)

      @deploy_config = fs.mktmpdir do |dir|
        signature.deploy.checkout(dir) do |working_dir|
          contents = YAML.safe_load(fs.read(working_dir.dir/"deploy.yml"))
          deploy_config_factory.from_hash(contents)
        end
      end
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
