# frozen_string_literal: true

require "fauxpaas/artifact"
require "pathname"

module Fauxpaas

  # Builds artifacts
  # @see Artifact
  class ArtifactBuilder
    def initialize(ref_repo:, factory:)
      @ref_repo = ref_repo
      @factory = factory
    end

    # Build an artifact in the system's temporary directory
    # @param signature [ReleaseSignature]
    # @return The result of factory.new, pointing at the path
    def build(signature)
      path = Pathname.new(Dir.mktmpdir)
      add_references!(signature, path)
      factory.new(path)
    end

    private

    attr_reader :ref_repo, :factory

    def add_references!(signature, path)
      [signature.source, signature.shared, signature.unshared].each do |ref|
        add_reference(ref, path)
      end
    end

    def add_reference(ref, path)
      ref_repo.resolve(ref)
        .cp(path)
        .write
    end

  end
end
