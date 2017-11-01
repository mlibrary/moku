# frozen_string_literal: true

require "pathname"
require "open3"
require "fauxpaas/release"

module Fauxpaas

  # Deploys using Capistrano
  class CapistranoDeployer
    def initialize(capfile_path, kernel = Open3)
      @capfile_path = Pathname.new capfile_path
      @kernel = kernel
    end

    def deploy(instance, reference: nil, release: Release, infrastructure_config_path:)
      _stdout, stderr, status = run(instance, "deploy", [
        "BRANCH=#{reference || instance.default_branch}",
        "INFRASTRUCTURE_PATH=#{infrastructure_config_path}"
      ])

      instance.log_release(release.new(find_revision(stderr))) if status.success?

      status
    end

    def rollback(instance, cache: nil)
      _stdout, _stderr, status = run(instance, "deploy:rollback", [rollback_cache_option(cache)])
      status
    end

    def caches(instance)
      _stdout, stderr, status = run(instance, "caches:list")
      stderr
        .split(Fauxpaas.split_token + "\n")
        .drop(1)
        .map {|dirs| dirs.split("\n") }
        .first
      status
    end

    def restart(instance)
      _stdout, stderr, status = run(instance, "systemd:restart")
      status
    end

    private

    attr_reader :capfile_path, :kernel

    def run(instance, task, options = [])
      kernel.capture3(
        "cap -f #{capfile_for(instance)} #{instance.name} #{task} #{options.join(" ")}".strip
      )
    end

    def capfile_for(instance)
      capfile_path + "#{instance.deployer_env}.capfile"
    end

    def rollback_cache_option(cache)
      if cache
        "ROLLBACK_RELEASE=#{cache}"
      else
        ""
      end
    end

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
