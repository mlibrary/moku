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

    def signature(source_reference = nil)
      if source_reference
        ReleaseSignature.new(
          source: source_archive.reference(source_reference),
          infrastructure: infrastructure_archive.latest,
          deploy: deploy_archive.latest
        )
      else
        ReleaseSignature.new(
          source: source_archive.latest,
          infrastructure: infrastructure_archive.latest,
          deploy: deploy_archive.latest
        )
      end
    end

    def release(sig)
      Release.new(
        source: sig.source,
        infrastructure: infrastructure_archive.infrastructure(sig.infrastructure),
        deploy_config: deploy_archive.deploy_config(sig.deploy)
      )
    end

    def runner
      @runner ||= deploy_archive
        .deploy_config(deploy_archive.latest)
        .runner
    end

    def caches
      # it likely does not make sense for the instance to manipulate
      # cap's raw output
      _, stderr, status = runner.run(name, "caches:list", {})
      stderr
        .split(Fauxpaas.split_token + "\n")
        .drop(1)
        .map {|dirs| dirs.split("\n") }
        .first
    end

    def rollback(cache = nil)
      _, _, status = runner.run(name, "deploy:rollback", {rollback_release: cache})
      status
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
