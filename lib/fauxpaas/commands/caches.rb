# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

    # Show the existing caches
    class Caches < Command
      def action
        :caches
      end

      def execute
        Fauxpaas.logger.info instance
          .interrogator
          .caches
      end
    end

  end
end
