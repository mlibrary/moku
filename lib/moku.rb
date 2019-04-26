# frozen_string_literal: true

require "moku/version"
require "moku/archive_reference"
require "moku/artifact"
require "moku/artifact_repo"
require "moku/auth_service"
require "moku/cached_bundle"
require "moku/cli"
require "moku/config"
require "moku/deploy_config"
require "moku/file_instance_repo"
require "moku/file_permissions_repo"
require "moku/instance"
require "moku/invoker"
require "moku/logged_release"
require "moku/logged_releases"
require "moku/policy"
require "moku/reference_repo"
require "moku/release"
require "moku/release_signature"
require "moku/scm/git"
require "moku/shell/basic"
require "moku/shell/passthrough"
require "moku/shell/remote_release"
require "moku/shell/secure_remote"
require "moku/upload"

require "logger"
require "pathname"
require "canister"

# Fake Platform As A Service
module Moku
  class << self

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/BlockLength
    # rubocop:disable Metrics/MethodLength
    def initialize!
      settings # eager load
      config.tap do |container| # rubocoop:
        if settings.verbose
          container.register(:logger) { Logger.new(STDOUT, level: :debug) }
          container.register(:system_runner) { Moku::Shell::Passthrough.new(STDOUT) }
        else
          container.register(:logger) { Logger.new(STDOUT, level: :info) }
          container.register(:system_runner) { Moku::Shell::Basic.new }
        end
        container.register(:remote_runner) {|c| Moku::Shell::SecureRemote.new(c.system_runner) }
        container.register(:upload_factory) { Moku::Upload }
        container.register(:git_runner) {|c| Moku::SCM::Git.new(system_runner: c.system_runner) }
        container.register(:artifact_repo) {|c| Moku::ArtifactRepo.new(c.build_root) }
        container.register(:ref_repo) do |c|
          Moku::ReferenceRepo.new(
            c.ref_root,
            c.git_runner
          )
        end
        container.register(:remote_context) do |c|
          Shell::RemoteRelease::Builder.new(remote_runner: c.remote_runner)
        end
        container.register(:instance_repo) do |c|
          Moku::FileInstanceRepo.new(
            instances_path: c.instance_root,
            releases_path: c.releases_root,
            branches_path: c.branches_root,
            git_runner: c.git_runner
          )
        end
        container.register(:permissions_repo) do |c|
          Moku::FilePermissionsRepo.new(c.instance_root)
        end
        container.register(:auth) do |c|
          data = c.permissions_repo.find
          Moku::AuthService.new(
            global: data.fetch(:all, {}),
            instances: data.fetch(:instances, {}),
            policy_factory: Moku::Policy
          )
        end

        container.register(:bundle_cache_path) do
          Pathname.new(settings.bundle_cache_path).expand_path(Moku.root)
        end
        container.register(:cached_bundle) do |c|
          Moku::CachedBundle.new(c.bundle_cache_path)
        end

        container.register(:invoker) { Moku::Invoker.new }
        [
          :instance_root,
          :releases_root,
          :deployer_env_root,
          :ref_root,
          :branches_root,
          :build_root,
          :default_root,
          :tmp_root,
          :locks_root
        ].each do |root|
          container.register(root) do
            Pathname.new(settings.public_send(root)).expand_path(Moku.root)
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/BlockLength
    # rubocop:enable Metrics/MethodLength

  end
end
