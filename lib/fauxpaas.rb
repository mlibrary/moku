# frozen_string_literal: true

require "fauxpaas/version"
require "fauxpaas/archive_reference"
require "fauxpaas/artifact"
require "fauxpaas/auth_service"
require "fauxpaas/cli"
require "fauxpaas/config"
require "fauxpaas/deploy_config"
require "fauxpaas/file_instance_repo"
require "fauxpaas/file_permissions_repo"
require "fauxpaas/filesystem"
require "fauxpaas/instance"
require "fauxpaas/invoker"
require "fauxpaas/logged_release"
require "fauxpaas/logged_releases"
require "fauxpaas/policy"
require "fauxpaas/reference_repo"
require "fauxpaas/release"
require "fauxpaas/release_signature"
require "fauxpaas/scm/git"
require "fauxpaas/shell/basic"
require "fauxpaas/shell/passthrough"
require "fauxpaas/shell/secure_remote"

require "logger"
require "pathname"
require "canister"

# Fake Platform As A Service
module Fauxpaas
  class << self

    def initialize!
      settings # eager load
      config.tap do |container|
        if settings.verbose
          container.register(:logger) { Logger.new(STDOUT, level: :debug) }
          container.register(:system_runner) { Fauxpaas::Shell::Passthrough.new(STDOUT) }
        else
          container.register(:logger) { Logger.new(STDOUT, level: :info) }
          container.register(:system_runner) { Fauxpaas::Shell::Basic.new }
        end
        container.register(:remote_runner) {|c| Fauxpaas::Shell::SecureRemote.new(c.system_runner) }
        container.register(:backend_runner) {|c| Fauxpaas::CapRunner.new(c.system_runner) }
        container.register(:filesystem) { Fauxpaas::Filesystem.new }
        container.register(:git_runner) do |c|
          Fauxpaas::GitRunner.new(
            system_runner: c.system_runner,
            fs: c.filesystem
          )
        end
        container.register(:ref_repo) do |c|
          Fauxpaas::ReferenceRepo.new(
            c.ref_root,
            c.git_runner
          )
        end
        container.register(:instance_repo) do |c|
          Fauxpaas::FileInstanceRepo.new(
            instances_path: c.instance_root,
            releases_path: c.releases_root,
            branches_path: c.branches_root,
            fs: c.filesystem,
            git_runner: c.git_runner
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
      end
    end

  end
end
