# frozen_string_literal: true

require "active_support/core_ext/hash/keys"
require "fauxpaas/cap"

module Fauxpaas

  # The deploy configuration used in the deployment of the instance. I.e. _how_ the
  # instance gets deployed.
  class DeployConfig

    def self.from_hash(hash)
      new(hash.symbolize_keys)
    end

    def initialize(hash = {})
      @hash = hash
      @hash[:systemd_services] ||= []
    end

    def respond_to?(method)
      super || hash.has_key?(method)
    end

    def method_missing(method, *args, &block)
      if respond_to?(method)
        hash.fetch(method)
      else
        super(method, args, &block)
      end
    end

    def runner
      Cap.new(
        to_hash.merge("deployer_env" => Fauxpaas.deployer_env_root + deployer_env),
        appname,
        Fauxpaas.backend_runner
      )
    end

    def to_hash
      hash.stringify_keys
    end

    def eql?(other)
      to_hash == other.to_hash
    end
    alias_method :==, :eql?

    private
    attr_reader :hash

  end
end
