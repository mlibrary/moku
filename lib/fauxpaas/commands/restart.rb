# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

    # Restart the application
    class Restart < Command
      def action
        :restart
      end

      def execute
        report(instance.interrogator.restart,
          action: "restart")
      end
    end

  end
end
