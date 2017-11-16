# frozen_string_literal: true

require "active_support/core_ext/hash/keys"
require "fauxpaas/components"
require "fauxpaas/filesystem"

module Fauxpaas

  # Capistrano
  class Cap
    def initialize(options, stage, runner, fs = Filesystem.new)
      @capfile_path, @common_options = parse_options(options)
      @stage = stage
      @runner = runner
      @fs = fs
    end

    def deploy(infrastructure, source)
      fs.mktmpdir do |dir|
        infrastructure_path = Pathname.new(dir) + "infrastructure.yml"
        fs.write(infrastructure_path, YAML.dump(infrastructure.to_hash))
        _, _, status = run("deploy",
          infrastructure_config_path: infrastructure_path.to_s,
          source_repo: source.url,
          branch: source.reference.to_s)
        status
      end
    end

    def caches
      _, stderr, _status = run("caches:list", {})
      stderr
        .split(Fauxpaas.split_token + "\n")
        .drop(1)
        .map {|dirs| dirs.split("\n") }
        .first
    end

    def rollback(source, cache)
      _stdout, _stderr, status = run("deploy:rollback",
        source_repo: source.url,
        branch: source.reference.to_s,
        rollback_release: cache)
      status
    end

    def restart
      _stdout, _stderr, status = run("systemd:restart", {})
      status
    end

    def syslog_view
      run("syslog:view", {})
    end

    def syslog_follow
      run("syslog:follow", {})
    end

    def syslog_grep(pattern)
      run("syslog:grep", grep_pattern: pattern)
    end

    private

    attr_reader :capfile_path, :stage, :runner, :fs, :common_options

    def parse_options(options)
      opts = options.symbolize_keys
      capfile_path = opts[:deployer_env]
      common_options = {
        application:      opts[:appname] || opts[:application],
        deploy_dir:       opts[:deploy_dir],
        rails_env:        opts[:rails_env],
        assets_prefix:    opts[:assets_prefix],
        systemd_services: opts.fetch(:systemd_services, []).join(":")
      }
      [capfile_path, common_options]
    end

    def run(task, more_options)
      runner.run(capfile_path, stage, task, common_options.merge(more_options))
    end

  end
end
