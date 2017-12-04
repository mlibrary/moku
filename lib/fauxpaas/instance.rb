# frozen_string_literal: true

require "fauxpaas/release_builder"
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
      release_builder.signature(sig_or_ref)
    end

    def release(sig_or_ref)
      release_builder.release(sig_or_ref)
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

    private
    def release_builder
      ReleaseBuilder.new(
        deploy_archive: deploy_archive,
        infrastructure_archive: infrastructure_archive,
        source_archive: source_archive
      )
    end

  end

end
