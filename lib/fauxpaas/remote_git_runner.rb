require "fauxpaas/git_runner"

module Fauxpaas
  class RemoteGitRunner < GitRunner
    def sha(url, commitish)
      stdout, _, _ = system_runner.run("git ls-remote #{url} #{commitish}")
      stdout
        .split("\n")
        .first
        &.split
        &.first
    end
  end
end
