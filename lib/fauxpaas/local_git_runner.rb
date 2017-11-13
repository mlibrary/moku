require "fauxpaas/git_runner"

module Fauxpaas
  class LocalGitRunner < GitRunner
    def sha(path, commitish)
      stdout, _, _ = system_runner.run("git -C #{path} rev-parse #{commitish}")
      stdout.strip
    end
  end
end
