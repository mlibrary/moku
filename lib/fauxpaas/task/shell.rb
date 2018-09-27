# frozen_string_literal: true

require "fauxpaas/task/task"

module Fauxpaas
  module Task

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
          runner.run(command)
        end
      end

      private

      attr_reader :runner
    end

  end
end
