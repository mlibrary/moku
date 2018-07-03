# frozen_string_literal: true

require "core_extensions/hash/keys"
require "fauxpaas/filesystem"

module Fauxpaas

  # Capistrano
  class Cap
    def initialize(options, stage, runner)
      @capfile_path, @common_options = parse_options(options)
      @stage = stage
      @runner = runner
    end

    # @param source [ArchiveReference]
    # @param shared_path [Pathname]
    # @param unshared_path [Pathname]
    def deploy(source, shared_path, unshared_path)
      _, _, status = run("deploy",
        shared_config_path: shared_path.to_s,
        unshared_config_path: unshared_path.to_s,
        source_repo: source.url,
        branch: source.commitish.to_s)
      status
    end

    def caches
      _, stderr, _status = run("caches:list", {})
      stderr
        .split(Fauxpaas.split_token + "\n")
        .drop(1)
        .map {|dirs| dirs.split("\n") }
        .first
    end

    # @param source [ArchiveReference]
    # @param cache [String]
    def rollback(source, cache)
      _stdout, _stderr, status = run("deploy:rollback",
        source_repo: source.url,
        branch: source.commitish.to_s,
        rollback_release: cache)
      status
    end

    def restart
      _stdout, _stderr, status = run("systemd:restart", {})
      status
    end

    # @param env [Hash] Environment variables to set before running the command
    # @param role [String] The role on which the command should be run
    # @param bin [String] The executable
    # @param args [String] Optional arguments as a single string
    def exec(env:, role:, bin:, args: "")
      stdout, stderr, status = run("commands:run_one",
        faux_vars: env.map{|pair| pair.join("=")}.join(":"),
        faux_bin: bin,
        faux_args: args,
        faux_role: role)
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

    attr_reader :capfile_path, :stage, :runner, :common_options

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
