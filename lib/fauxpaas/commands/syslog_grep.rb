# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

    # Grep the system logs
    class SyslogGrep < Command
      def initialize(instance_name:, user:, pattern:)
        super(instance_name: instance_name, user: user)
        @pattern = pattern
      end

      attr_reader :pattern

      def action
        :syslog_grep
      end

      def execute
        instance.interrogator.syslog_grep(pattern)
      end
    end

  end
end
