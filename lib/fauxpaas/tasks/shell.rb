# frozen_string_literal: true

require "fauxpaas/tasks/task"

module Fauxpaas
  module Tasks

    # A simple shell task, resolved in the context of the target.
    class Shell < Task
      def initialize(command, runner: Fauxpaas.system_runner)
        @command = command
        @runner = runner
      end

      attr_reader :command

      # @param target [Artifact,Release]
      def call(target)
        with_env(target.path) do
          _, stderr, status = runner.run(command)
          Status.new(status.success?, stderr)
        end
      end

      private

      attr_reader :runner
    end

  end
end
