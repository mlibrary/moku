# frozen_string_literal: true

require "fauxpaas/components/git_runner"
require "pathname"

module Fauxpaas

  # Fully identifies a commit or other reference within a git repository.
  class GitReference
    def self.from_hash(hash)
      new(hash[:url], hash[:reference])
    end

    def initialize(url, reference)
      @url = url
      @reference = reference
    end

    attr_reader :url, :reference

    def eql?(other)
      reference == other.reference &&
        url == other.url
    end

    def to_hash
      {
        url:       url,
        reference: reference
      }
    end
  end
end
