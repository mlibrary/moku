# frozen_string_literal: true

module Fauxpaas
  module SCM
    class Git

      # Git ref resolver for local repositories.
      class LocalResolver
        def initialize(system_runner)
          @system_runner = system_runner
        end

        def sha(path, commitish)
          system_runner.run("git -C #{path} rev-parse #{commitish}")
            .output
            .strip
        end

        private

        attr_reader :system_runner
      end

    end
  end
end
