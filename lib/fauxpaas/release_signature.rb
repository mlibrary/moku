# frozen_string_literal: true

require "fauxpaas/archive_reference"

module Fauxpaas

  # Uniquely identifies an app at a point in time, including the machinery
  # used to deploy it.
  class ReleaseSignature

    def self.from_hash(hash)
      new(
        source: ArchiveReference.from_hash(hash[:source]),
        deploy: ArchiveReference.from_hash(hash[:deploy]),
        shared: ArchiveReference.from_hash([hash.fetch(:shared, [])].flatten.first),
        unshared: ArchiveReference.from_hash([hash.fetch(:unshared, [])].flatten.first)
      )
    end

    # @param source [ArchiveReference]
    # @param deploy [ArchiveReference]
    # @param shared [ArchiveReference]
    # @param unshared [ArchiveReference]
    def initialize(source:, deploy:, shared:, unshared:)
      @source = source
      @deploy = deploy
      @shared = shared
      @unshared = unshared
    end

    attr_reader :source, :deploy, :shared, :unshared

    def eql?(other)
      to_hash == other.to_hash
    end

    def to_hash
      {
        source:   source.to_hash,
        deploy:   deploy.to_hash,
        shared:   shared.to_hash,
        unshared: unshared.to_hash
      }
    end
  end

end
