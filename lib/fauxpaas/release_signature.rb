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
        shared: hash.fetch(:shared, []).map do |h|
          ArchiveReference.from_hash(h)
        end,
        unshared: hash.fetch(:unshared, []).map do |h|
          ArchiveReference.from_hash(h)
        end
      )
    end

    # @param source [ArchiveReference]
    # @param deploy [ArchiveReference]
    # @param shared [Array<ArchiveReference>]
    # @param unshared [Array<ArchiveReference>]
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
        shared:   shared.map(&:to_hash),
        unshared: unshared.map(&:to_hash)
      }
    end
  end

end
