# frozen_string_literal: true

require "core_extensions/hash/keys"
require "fauxpaas/sites"
require "pathname"
require "yaml"

module Fauxpaas

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
        systemd_services: tmp[:systemd_services] || [],
        sites: Sites.new(tmp[:sites])
      )
    end

    # @param dir [Lazy::Directory]
    def self.from_dir(dir, filename: Fauxpaas.deploy_config_filename)
      from_hash(YAML.load(File.read((dir.path/filename).to_s))) # rubocop:disable Security/YAMLLoad
    end

    # @param ref [ArchiveReference]
    # @param ref_repo [ReferenceRepo]
    def self.from_ref(ref, ref_repo)
      from_dir(ref_repo.resolve(ref))
    end

    def initialize(deploy_dir:, env:, systemd_services:, sites:)
      @deploy_dir = Pathname.new(deploy_dir).expand_path(Fauxpaas.root)
      @env = env
      @systemd_services = systemd_services
      @sites = sites
    end

    attr_reader :deploy_dir, :sites, :systemd_services

    def shell_env
      @shell_env ||= env.keep_if {|_key, value| value }
        .map {|key, value| "#{key.to_s.upcase}=#{Shellwords.escape(value)}" }
        .join(" ")
    end

    def eql?(other)
      deploy_dir == other.deploy_dir &&
        systemd_services == other.systemd_services &&
        sites.hosts == other.sites.hosts &&
        shell_env == other.shell_env
    end

    private

    attr_reader :env

  end
end
