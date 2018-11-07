# frozen_string_literal: true

require "moku"
require "moku/command/command"

module Moku

  module Command
    # Create and deploy a release
    class Deploy < Command
      def initialize(instance_name:, user:, reference: nil)
        super(instance_name: instance_name, user: user)
        @reference = reference
      end

      def action
        :deploy
      end

      def reference
        @reference || instance.default_branch
      end
    end

  end
end
