# frozen_string_literal: true

require "fauxpaas/git_runner"

module Fauxpaas

  # GitRunner for local repositories.
  class LocalGitRunner < GitRunner
    def sha(path, commitish)
      stdout, = system_runner.run("git -C #{path} rev-parse #{commitish}")
      stdout.strip
    end
  end
end
