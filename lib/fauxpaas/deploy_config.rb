# frozen_string_literal: true

require "core_extensions/hash/keys"
require "fauxpaas/cap"
require "ostruct"
require "yaml"

module Fauxpaas

  # The deploy configuration used in the deployment of the instance. I.e. _how_ the
  # instance gets deployed.
  class DeployConfig < OpenStruct

    # @param hash [Hash]
    def self.from_hash(hash)
      new(hash.symbolize_keys)
    end

    # @param dir [Lazy::Directory]
    def self.from_dir(dir)
      from_hash(YAML.load(File.read(dir.path/"deploy.yml")))
    end

    # @param ref [ArchiveReference]
    # @param ref_repo [ReferenceRepo]
    def self.from_ref(ref, ref_repo)
      from_dir(ref_repo.resolve(ref))
    end

    def initialize(hash = {})
      hash[:systemd_services] ||= []
      hash[:deploy_dir] = Pathname.new(hash[:deploy_dir]).expand_path(Fauxpaas.project_root).to_s
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
