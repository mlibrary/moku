# frozen_string_literal: true

module Fauxpaas

  # Git ref resolver for local repositories.
  class LocalGitResolver
    def initialize(system_runner)
      @system_runner = system_runner
    end

    def sha(path, commitish)
      stdout, = system_runner.run("git -C #{path} rev-parse #{commitish}")
      stdout.strip
    end

    private
    attr_reader :system_runner
  end
end
