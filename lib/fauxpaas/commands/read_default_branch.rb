# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

    # Show the instance's default source branch
    class ReadDefaultBranch < Command
      def action
        :read_default_branch
      end

      def execute
        Fauxpaas.logger.info "Default branch: #{instance.default_branch}"
      end
    end

  end
end
