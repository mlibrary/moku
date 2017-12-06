# frozen_string_literal: true

module Fauxpaas

  # Git ref resolver for remote repositories.
  class RemoteGitResolver
    def initialize(system_runner)
      @system_runner = system_runner
    end

    def sha(url, commitish)
      stdout, = system_runner.run("git ls-remote #{url} #{commitish}")
      stdout
        .split("\n")
        .first
        &.split
        &.first
    end

    private
    attr_reader :system_runner
  end
end
