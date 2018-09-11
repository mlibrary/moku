# frozen_string_literal: true

require "fauxpaas/release"
require "fauxpaas/deploy_config"
require "pathname"

module Fauxpaas

  # Build a release from a signature
  class ReleaseBuilder

    # @param ref_repo [ReferenceRepo]
    def initialize(ref_repo)
      @ref_repo = ref_repo
    end

    # @param signature [ReleaseSignature]
    # @return [Release]
    def build(signature)
      dir = Pathname.new(Dir.mktmpdir)
      Release.new(
        shared_path: extract_ref(signature.shared, dir/"shared"),
        unshared_path: extract_ref(signature.unshared, dir/"unshared"),
        deploy_config: deploy_config(signature),
        source_path: extract_ref(signature.source, dir/"source")
      )
    end

    private

    attr_reader :ref_repo

    def deploy_config(signature)
      @deploy_config ||= DeployConfig.from_ref(signature.deploy, ref_repo)
    end

    def extract_ref(ref, path)
      ref_repo.resolve(ref)
        .cp(path)
        .write
        .path
    end

  end
end
