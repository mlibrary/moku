# frozen_string_literal: true

module Moku
  module SCM
    class Git

      # Git ref resolver for remote repositories.
      class RemoteResolver
        def initialize(system_runner)
          @system_runner = system_runner
        end

        def sha(url, commitish)
          system_runner.run("git ls-remote #{url} #{commitish}")
            .output
            .split("\n")
            .first
            &.split
            &.first
        end

        private

        attr_reader :system_runner
      end

    end
  end
end
