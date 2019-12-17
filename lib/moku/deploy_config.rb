# frozen_string_literal: true

require "core_extensions/hash/keys"
require "moku/sites"
require "pathname"
require "yaml"

module Moku

  # The deploy configuration used in the deployment of the instance. I.e. _how_ the
  # instance gets deployed.
  class DeployConfig

    # @param hash [Hash]
    def self.from_hash(hash)
      tmp = hash.symbolize_keys
      tmp.default_proc = proc {|h, key| h[key] = {} }
      rack_env = tmp[:env][:rack_env] || tmp[:rack_env] || tmp[:rails_env]
      env = tmp[:env].merge(rack_env: rack_env)

      new(
        deploy_dir: tmp[:deploy_dir],
        env: env,
        target_type: tmp[:target_type] || "app_host",
        uid: tmp[:uid] || 1000,
        gid: tmp[:gid] || 1000,
        systemd_services: tmp[:systemd_services] || [],
        sites: Sites.for(tmp[:sites])
      )
    end

    # @param dir [Pathname]
    def self.from_dir(dir, filename: Moku.deploy_config_filename)
      from_hash(YAML.load(File.read((dir/filename).to_s))) # rubocop:disable Security/YAMLLoad
    end

    # @param ref [ArchiveReference]
    # @param ref_repo [ReferenceRepo]
    def self.from_ref(ref, ref_repo)
      from_dir(ref_repo.resolve(ref))
    end

    # @param deploy_dir [Pathname]
    # @param env [Hash<Symbol, String>]
    # @param target_type [String]
    # @param systemd_services [Array<String>]
    # @param sites [Sites]
    def initialize(deploy_dir:, env:, target_type:, systemd_services:, sites:, uid:, gid:)
      @deploy_dir = Pathname.new(deploy_dir)
      @env = env
      @target_type = target_type
      @systemd_services = systemd_services
      @sites = sites
      @uid = uid
      @gid = gid
    end

    attr_reader :deploy_dir, :target_type, :sites, :systemd_services, :env, :uid, :gid

    def eql?(other)
      deploy_dir == other.deploy_dir &&
        systemd_services == other.systemd_services &&
        sites.hosts == other.sites.hosts
    end

  end
end
