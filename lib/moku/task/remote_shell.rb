# frozen_string_literal: true

require "moku/task/task"
require "moku/status"

module Moku
  module Task

    # A shell task that is resolved in the context of the deployed
    # release on each target host.
    class RemoteShell < Task
      def initialize(command:, per:)
        @command = command
        @per = per
      end

      attr_reader :command, :per

      # @param target [Release]
      def call(release)
        return Status.failure("Must specify a command") unless command
        return Status.failure("Must specify per") unless per

        release.public_send(:"run_per_#{per}", command)
      end
    end

  end
end
