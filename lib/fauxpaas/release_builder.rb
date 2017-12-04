require "fauxpaas/release_signature"
require "fauxpaas/release"

module Fauxpaas
  class ReleaseBuilder
    def initialize(deploy_archive:, infrastructure_archive:, source_archive:)
      @deploy_archive = deploy_archive
      @infrastructure_archive = infrastructure_archive
      @source_archive = source_archive
    end

    def signature(sig_or_ref = nil)
      return sig_or_ref if sig_or_ref.is_a?(ReleaseSignature)
      ReleaseSignature.new(
        deploy: deploy_archive.latest,
        infrastructure: infrastructure_archive.latest,
        source: source_archive.reference(sig_or_ref)
      )
    end

    def release(sig_or_ref)
      sig = signature(sig_or_ref)
      Release.new(
        deploy_config: deploy_archive.deploy_config(sig.deploy),
        infrastructure: infrastructure_archive.infrastructure(sig.infrastructure),
        source: sig.source
      )
    end

    private
    attr_reader :deploy_archive, :infrastructure_archive, :source_archive

  end
end
