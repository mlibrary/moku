# frozen_string_literal: true

require "moku/task/task"
require "moku/status"

module Moku
  module Task

    # A shell task that is resolved in the context of the deployed
    # release on each target host.
    class RemoteShell < Task

      def self.from_spec(task_spec)
        new(command: task_spec.command, scope: task_spec.scope)
      end

      def initialize(command:, scope:)
        @command = command
        @scope = scope
      end

      attr_reader :command, :scope

      # @param target [Release]
      def call(release)
        return Status.failure("Must specify a command") unless command
        return Status.failure("Must specify scope") unless scope

        release.run(scope, command)
      end
    end

  end
end
