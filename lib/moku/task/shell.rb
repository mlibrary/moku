# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    # A simple shell task, resolved in the context of the target.
    class Shell < Task
      def initialize(command:, runner: Moku.system_runner)
        @command = command
        @runner = runner
      end

      def to_s
        "#{self.class}(#{command})"
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
