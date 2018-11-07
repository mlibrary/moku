# frozen_string_literal: true

require "moku"
require "moku/command/command"

module Moku
  module Command

    # Show the instance's default source branch
    class ReadDefaultBranch < Command
      def action
        :read_default_branch
      end
    end

  end
end
