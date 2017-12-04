require "fauxpaas/release_signature"
require "fauxpaas/release"

module Fauxpaas
  class ReleaseBuilder
    def initialize(deploy_archive:, infrastructure_archive:, source_archive:)
      @deploy_archive = deploy_archive
      @infrastructure_archive = infrastructure_archive
      @source_archive = source_archive
    end

    def signature(reference = nil)
      ReleaseSignature.new(
        deploy: deploy_archive.latest,
        infrastructure: infrastructure_archive.latest,
        source: source_archive.reference(reference)
      )
    end

    def release(signature)
      Release.new(
        deploy_config: deploy_archive.deploy_config(signature.deploy),
        infrastructure: infrastructure_archive.infrastructure(signature.infrastructure),
        source: signature.source
      )
    end

    private
    attr_reader :deploy_archive, :infrastructure_archive, :source_archive

  end
end
