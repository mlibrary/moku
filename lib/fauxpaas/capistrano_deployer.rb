# frozen_string_literal: true

require "pathname"
require "open3"
require "fauxpaas/components"
require "fauxpaas/release"
require "fauxpaas/open3_capture"
require "fauxpaas/cap_runner"

module Fauxpaas

  # Deploys using Capistrano
  class CapistranoDeployer
    def initialize(capfile_path, runner = nil, kernel = Open3Capture)
      @runner = runner || CapRunner.new(Pathname.new(capfile_path), kernel)
    end

    def deploy(instance, reference: nil, release: Release, infrastructure_config_path:)
      _, stderr, status = runner.run(instance.name, "deploy", {
        branch: reference || instance.default_branch,
        infrastructure_path: infrastructure_config_path,
        deploy_dir: instance.deploy_dir,
        rails_env: instance.rails_env,
        assets_prefix: instance.assets_prefix,
        source_repo: instance.source_repo
      })

      instance.log_release(release.new(find_revision(stderr))) if status.success?

      status
    end

    def rollback(instance, cache: nil)
      _, _, status = runner.run(instance.name, "deploy:rollback", {rollback_release: cache})
      status
    end

    def caches(instance)
      _, stderr, status = runner.run(instance.name, "caches:list", {})
      stderr
        .split(Fauxpaas.split_token + "\n")
        .drop(1)
        .map {|dirs| dirs.split("\n") }
        .first
      status
    end

    private
    attr_reader :runner

    def find_revision(stderr)
      ensure_match(stderr.split("\n")
        .find(-> { "" }) {|_s| /deployed as release/ }
        .match(/\(at ([0-9a-f]{40})\)/),
        no_match: "Can't find revision in capistrano stderr")
    end

    def ensure_match(match, no_match: "No match")
      if match
        match.captures[0]
      else
        raise no_match
      end
    end

  end

end
