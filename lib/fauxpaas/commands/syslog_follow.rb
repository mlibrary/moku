# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

    # tail -f the system logs
    class SyslogFollow < Command
      def action
        :syslog_follow
      end

      def execute
        instance.interrogator.syslog_follow
      end
    end

  end
end
