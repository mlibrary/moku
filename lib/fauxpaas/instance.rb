# frozen_string_literal: true

require "fauxpaas/release_signature"
require "fauxpaas/release"
require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance
    def initialize(name:, releases: [], infrastructure_archive:, deploy_archive:, source_archive:)
      @name = name
      @app, @stage = name.split("-")
      @releases = releases
      @infrastructure_archive = infrastructure_archive
      @deploy_archive = deploy_archive
      @source_archive = source_archive
    end

    attr_reader :name, :app, :stage, :releases
    attr_reader :source_archive, :deploy_archive, :infrastructure_archive

    def signature(sig_or_ref = nil)
      return sig_or_ref if sig_or_ref.kind_of?(ReleaseSignature)
      ReleaseSignature.new(
        source: source_archive.reference(sig_or_ref),
        infrastructure: infrastructure_archive.latest,
        deploy: deploy_archive.latest
      )
    end

    def release(sig_or_ref)
      sig = signature(sig_or_ref)
      Release.new(
        source: sig.source,
        infrastructure: infrastructure_archive.infrastructure(sig.infrastructure),
        deploy_config: deploy_archive.deploy_config(sig.deploy)
      )
    end

    def interrogator
      deploy_archive
        .deploy_config(deploy_archive.latest)
        .runner
    end

    def default_branch
      source_archive.default_branch
    end

    def default_branch=(value)
      source_archive.default_branch = value
    end

    def eql?(other)
      name == other.name &&
        source_archive == other.source_archive &&
        deploy_archive == other.deploy_archive &&
        infrastructure_archive == other.infrastructure_archive &&
        releases == other.releases
    end
    alias_method :==, :eql?

    def log_release(release)
      releases << release
    end

  end

end
