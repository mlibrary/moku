require "fauxpaas/components"
require "fauxpaas/filesystem"

module Fauxpaas
  class Cap
    def initialize(capfile_path, stage, runner, fs = Filesystem.new)
      @capfile_path = capfile_path
      @stage = stage
      @runner = runner
      @fs = fs
    end

    def deploy(infrastructure, options)
      fs.mktmpdir do |dir|
        infrastructure_path = Pathname.new(dir) + "infrastructure.yml"
        fs.write(infrastructure_path, YAML.dump(infrastructure.to_hash))
        _,_,status = run(
          "deploy",
          options.merge(infrastructure_config_path: infrastructure_path.to_s)
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

    def rollback(cache)
      _, _, status = run("deploy:rollback", {rollback_release: cache})
      status
    end

    private
    attr_reader :capfile_path, :stage, :runner, :fs

    def run(task, options)
      runner.run(capfile_path, stage, task, options.merge(application: stage))
    end

  end
end
