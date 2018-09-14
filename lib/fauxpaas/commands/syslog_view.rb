# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

    # View the system logs
    class SyslogView < Command
      def action
        :syslog_view
      end

      def execute
        instance.interrogator.syslog_view
      end
    end

  end
end
