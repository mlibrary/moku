# frozen_string_literal: true

require "fauxpaas/version"
require "fauxpaas/archive_reference"
require "fauxpaas/artifact"
require "fauxpaas/artifact_builder"
require "fauxpaas/auth_service"
require "fauxpaas/cap"
require "fauxpaas/cap_runner"
require "fauxpaas/cli"
require "fauxpaas/deploy_config"
require "fauxpaas/file_instance_repo"
require "fauxpaas/file_permissions_repo"
require "fauxpaas/filesystem"
require "fauxpaas/git_runner"
require "fauxpaas/instance"
require "fauxpaas/local_git_resolver"
require "fauxpaas/logged_release"
require "fauxpaas/logged_releases"
require "fauxpaas/open3_capture"
require "fauxpaas/passthrough_runner"
require "fauxpaas/policy"
require "fauxpaas/reference_repo"
require "fauxpaas/release"
require "fauxpaas/release_signature"
require "fauxpaas/remote_git_resolver"
require "fauxpaas/invoker"
require "fauxpaas/file_runner"

require "logger"
require "pathname"
require "canister"
require "ettin"

# Fake Platform As A Service
module Fauxpaas
  class << self
    attr_reader :config, :settings
    attr_writer :config, :env

    def respond_to_missing?(method_name, include_private = false)
      config.respond_to?(method_name) || super
    end

    def method_missing(method, *args, &block)
      if config.respond_to?(method)
        config.send(method, *args, &block)
      else
        super
      end
    end

    def root
      @root ||= Pathname.new(__FILE__).dirname.parent
    end

    def env
      @env ||= ENV["FAUXPAAS_ENV"] || ENV["RAILS_ENV"] || "development"
    end

    def reset!
      @settings = nil
      @loaded = false
      @config = nil
    end

    def load_settings!(hash = {})
      @settings = Ettin.for(Ettin.settings_files(root/"config", env))
      @settings.merge!(hash)
    end

    def initialize!
      load_settings! unless @settings
      @config ||= Canister.new.tap do |container|
        if settings.verbose
          container.register(:logger) { Logger.new(STDOUT, level: :debug) }
          container.register(:system_runner) { Fauxpaas::PassthroughRunner.new(STDOUT) }
        else
          container.register(:logger) { Logger.new(STDOUT, level: :info) }
          container.register(:system_runner) { Fauxpaas::Open3Capture.new }
        end
        container.register(:backend_runner) {|c| Fauxpaas::CapRunner.new(c.system_runner) }
        container.register(:filesystem) { Fauxpaas::Filesystem.new }
        container.register(:git_runner) do |c|
          Fauxpaas::GitRunner.new(
            system_runner: c.system_runner,
            fs: c.filesystem,
            local_resolver: Fauxpaas::LocalGitResolver.new(c.system_runner),
            remote_resolver: Fauxpaas::RemoteGitResolver.new(c.system_runner)
          )
        end
        container.register(:ref_repo) do |c|
          Fauxpaas::ReferenceRepo.new(
            c.ref_root,
            c.git_runner
          )
        end
        container.register(:artifact_builder) do |c|
          Fauxpaas::ArtifactBuilder.new(
            factory: Artifact,
            ref_repo: c.ref_repo,
            runner: c.system_runner
          )
        end
        container.register(:instance_repo) do |c|
          Fauxpaas::FileInstanceRepo.new(
            c.instance_root,
            c.releases_root,
            c.filesystem,
            c.git_runner,
            c.branches_root
          )
        end
        container.register(:permissions_repo) do |c|
          Fauxpaas::FilePermissionsRepo.new(c.instance_root)
        end
        container.register(:auth) do |c|
          data = c.permissions_repo.find
          Fauxpaas::AuthService.new(
            global: data.fetch(:all, {}),
            instances: data.fetch(:instances, {}),
            policy_factory: Fauxpaas::Policy
          )
        end

        container.register(:invoker) { Fauxpaas::Invoker.new }
        container.register(:instance_root) do
          Pathname.new(settings.instance_root).expand_path(Fauxpaas.root)
        end
        container.register(:releases_root) do
          Pathname.new(settings.releases_root).expand_path(Fauxpaas.root)
        end
        container.register(:deployer_env_root) do
          Pathname.new(settings.deployer_env_root).expand_path(Fauxpaas.root)
        end
        container.register(:ref_root) do
          Pathname.new(settings.ref_root).expand_path(Fauxpaas.root)
        end
        container.register(:branches_root) do
          Pathname.new(settings.branches_root).expand_path(Fauxpaas.root)
        end
        container.register(:split_token) { settings.split_token.chomp }
        container.register(:unshared_name) { settings.unshared_name.chomp }
        container.register(:shared_name) { settings.shared_name.chomp }
      end
    end

  end
end
