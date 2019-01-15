# frozen_string_literal: true

require "moku/archive_reference"

module Moku

  # Uniquely identifies an app at a point in time, including the machinery
  # used to deploy it.
  class ReleaseSignature

    def self.from_hash(hash)
      new(
        source: ArchiveReference.from_hash(hash[:source]),
        deploy: ArchiveReference.from_hash(hash[:deploy]),
        infrastructure: ArchiveReference.from_hash([hash.fetch(:infrastructure, [])].flatten.first),
        dev:    ArchiveReference.from_hash([hash.fetch(:dev, [])].flatten.first)
      )
    end

    # @param source [ArchiveReference]
    # @param deploy [ArchiveReference]
    # @param infrastructure [ArchiveReference]
    # @param dev [ArchiveReference]
    def initialize(source:, deploy:, infrastructure:, dev:)
      @source = source
      @deploy = deploy
      @infrastructure = infrastructure
      @dev = dev
    end

    attr_reader :source, :deploy, :infrastructure, :dev

    def eql?(other)
      to_hash == other.to_hash
    end

    def to_hash
      {
        source:   source.to_hash,
        deploy:   deploy.to_hash,
        infrastructure:   infrastructure.to_hash,
        dev:      dev.to_hash
      }
    end
  end

end
