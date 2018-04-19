# frozen_string_literal: true

require "core_extensions/hash/keys"
require "fauxpaas/cap"
require "ostruct"

module Fauxpaas

  # The deploy configuration used in the deployment of the instance. I.e. _how_ the
  # instance gets deployed.
  class DeployConfig < OpenStruct

    def self.from_hash(hash)
      new(hash.symbolize_keys)
    end

    def initialize(hash = {})
      hash[:systemd_services] ||= []
      super(hash)
      freeze
    end

    def runner
      Cap.new(
        to_hash.merge("deployer_env" => Fauxpaas.deployer_env_root + deployer_env),
        appname,
        Fauxpaas.backend_runner
      )
    end

    def to_hash
      marshal_dump.stringify_keys
    end
    alias_method :to_h, :to_hash
  end
end
