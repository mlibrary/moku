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

    def signature(reference = nil)
      ReleaseSignature.new(
        deploy: deploy_archive.latest,
        infrastructure: infrastructure_archive.latest,
        source: source_archive.at(reference)
      )
    end

    def release(signature)
      release_builder.release(signature)
    end

    def interrogator
      deploy_archive
        .deploy_config(deploy_archive.latest)
        .runner
    end

    def default_branch
      source_archive.commitish
    end

    def default_branch=(value)
      @source_archive = source_archive.at(value)
    end

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
