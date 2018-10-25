# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/command/command"

module Fauxpaas
  module Command

    # Show the instance's default source branch
    class ReadDefaultBranch < Command
      def action
        :read_default_branch
      end
    end

  end
end
