# frozen_string_literal: true

require "moku"
require "moku/command/command"
require "moku/pipeline/deploy"

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

      def call
        Pipeline::Deploy.new(
          instance: instance,
          user: user,
          reference: reference
        ).call
      end

      private

      def reference
        @reference || instance.default_branch
      end
    end

  end
end
