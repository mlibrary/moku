# frozen_string_literal: true

require "fauxpaas/git_runner"

module Fauxpaas

  # GitRunner for remote repositories.
  class RemoteGitRunner < GitRunner
    def sha(url, commitish)
      stdout, = system_runner.run("git ls-remote #{url} #{commitish}")
      stdout
        .split("\n")
        .first
        &.split
        &.first
    end
  end
end
