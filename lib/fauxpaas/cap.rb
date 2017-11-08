module Fauxpaas
  class Cap
    def initialize(capfile_path, runner)
      @capfile_path = capfile_path
      @runner = runner
    end

    def run(stage, task, options)
      runner.run(capfile_path, stage, task, options)
    end

    private
    attr_reader :capfile_path, :runner

  end
end
