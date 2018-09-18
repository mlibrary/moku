# frozen_string_literal: true

require "fauxpaas/tasks/task"
require "tmpdir"

module Fauxpaas
  module Tasks

    # Retrieve and install the artifact's gems (as defined by its Gemfile)
    class Bundle < Task
      # @param runner A system runner
      def initialize(runner: Fauxpaas.system_runner)
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
        _, _, status = runner.run(command)
        if status.success?
          Status.success
        else
          Status.failure(error)
        end
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
