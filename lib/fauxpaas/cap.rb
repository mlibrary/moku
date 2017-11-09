module Fauxpaas
  class Cap
    def initialize(capfile_path, stage, runner)
      @capfile_path = capfile_path
      @stage = stage
      @runner = runner
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
    attr_reader :capfile_path, :stage, :runner

    def run(task, options)
      runner.run(capfile_path, stage, task, options)
    end

  end
end
