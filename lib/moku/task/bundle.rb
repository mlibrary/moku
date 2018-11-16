# frozen_string_literal: true

require "moku/task/task"
require "tmpdir"

module Moku
  module Task

    # Retrieve and install the artifact's gems (as defined by its Gemfile)
    class Bundle < Task
      # @param runner A system runner
      def initialize(runner: Moku.system_runner)
        @runner = runner
      end

      # @param artifact [Artifact]
      # @return [Status]
      def call(artifact)
        with_env(artifact.path) { run }
      end

      private

      attr_reader :runner

      def run
        runner.run(command)
      end

      def command
        "bundle install --deployment '--without=development test'"
      end

      def error
        "Failed to install gems"
      end
    end

  end
end
