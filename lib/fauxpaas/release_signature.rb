# frozen_string_literal: true

module Fauxpaas

  # Uniquely identifies an app at a point in time, including the machinery
  # used to deploy it.
  class ReleaseSignature

    def self.from_hash(hash)
      new(
        source: ArchiveReference.from_hash(hash[:source]),
        infrastructure: ArchiveReference.from_hash(hash[:infrastructure]),
        deploy: ArchiveReference.from_hash(hash[:deploy])
      )
    end

    # @param source [ArchiveReference]
    # @param infrastructure [ArchiveReference]
    # @param deploy [ArchiveReference]
    def initialize(source:, infrastructure:, deploy:)
      @source = source
      @infrastructure = infrastructure
      @deploy = deploy
    end

    attr_reader :source, :infrastructure, :deploy

    def eql?(other)
      to_hash == other.to_hash
    end

    def to_hash
      {
        source:         source.to_hash,
        infrastructure: infrastructure.to_hash,
        deploy:         deploy.to_hash
      }
    end
  end

end
