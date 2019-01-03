# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    # A simple shell task, resolved in the context of the artifact.
    class Shell < Task

      def self.from_spec(task_spec)
        new(command: task_spec.command)
      end

      def initialize(command:)
        @command = command
      end

      def to_s
        "#{self.class}(#{command})"
      end

      attr_reader :command

      # @param artifact [Artifact]
      def call(artifact)
        artifact.run(command)
      end

    end

  end
end
