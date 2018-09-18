# frozen_string_literal: true

require "forwardable"

module Fauxpaas

  # A set of files on disk as they will be uploaded to an
  # application server.
  # An artifact is the result of a complete build phase. It contains all of
  # the source files, config files, and generated components. Artifacts are
  # isolated from external services, and generation of artifacts is idempotent.
  #
  # Internally, artifacts are files on disk under a top level directory. The arrangement
  # of these files is part of the API.  Artifacts are deployed to target hosts in the
  # deploy phase.
  #
  # While this class represents the artifact itself, and should therefore be the source
  # of information about the artifact, the responsibility for building it lies elsewhere.
  class Artifact
    extend Forwardable

    # Where should the path come from? (It shouldn't be Dir.mktmpdir)
    # Do we want the signature here?
    # @param path [Pathname] The top-level directory under which to construct the artifact.
    #   This path should exist.
    # @param signature [ReleaseSignature] A signature identifying the references that should
    #   be used in the construction of this artifact.
    def initialize(path:, signature:)
      @path = path
      @signature = signature
    end

    # The path of the top-level directory where this artifact is located.
    # @return [Pathname]
    attr_reader :path

    # @!method source
    #   This artifact's source
    #   @return [ArchiveReference]
    # @!method shared
    #   This artifact's shared config, i.e. the infrastructure config
    #   @return [ArchiveReference]
    # @!method source
    #   This artifact's unshared config, i.e. the developer config
    #   @return [ArchiveReference]
    def_delegators :@signature, :source, :shared, :unshared

    private

    attr_reader :plan, :signature

  end
end
