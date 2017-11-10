require "active_support/core_ext/hash/keys"
require "fauxpaas/components"
require "fauxpaas/filesystem"

module Fauxpaas
  class Cap
    def initialize(options, stage, runner, fs = Filesystem.new)
      options = options.symbolize_keys
      @common_options ||= {
        application: options[:appname] || options[:application],
        deploy_dir: options[:deploy_dir],
        rails_env: options[:rails_env],
        assets_prefix: options[:assets_prefix]
      }
      @capfile_path = options[:deployer_env]
      @stage = stage
      @runner = runner
      @fs = fs
    end

    def deploy(infrastructure, source)
      fs.mktmpdir do |dir|
        infrastructure_path = Pathname.new(dir) + "infrastructure.yml"
        fs.write(infrastructure_path, YAML.dump(infrastructure.to_hash))
        _,_,status = run(
          "deploy",
          {
            infrastructure_config_path: infrastructure_path.to_s,
            source_repo: source.url,
            branch: source.reference.to_s,
          }
        )
        status
      end
    end

    def caches
      _, stderr, status = run("caches:list", {})
      stderr
        .split(Fauxpaas.split_token + "\n")
        .drop(1)
        .map {|dirs| dirs.split("\n") }
        .first
    end

    def rollback(source, cache)
      stdout, stderr, status = run("deploy:rollback",
        {
          source_repo: source.url,
          branch: source.reference.to_s,
          rollback_release: cache
        }
      )
      status
    end

    private
    attr_reader :capfile_path, :stage, :runner, :fs, :common_options

    def run(task, more_options)
      runner.run(capfile_path, stage, task, common_options.merge(more_options))
    end

  end
end
