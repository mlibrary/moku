# frozen_string_literal: true

require "pathname"
require "active_support/core_ext/hash/keys"

module Fauxpaas

  # The infrastructure configuration needed by the instance
  class Infrastructure
    def self.from_hash(hash)
      new(hash)
    end

    def initialize(options)
      @options = options.stringify_keys
    end

    def to_hash
      options.stringify_keys
    end

    def eql?(other)
      to_hash == other.to_hash
    end
    alias_method :==, :eql?

    private

    attr_reader :options
  end
end
