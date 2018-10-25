# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/command/command"

module Fauxpaas
  module Command

    # Show the releases
    class Releases < Command
      def initialize(instance_name:, user:, long: false)
        super(instance_name: instance_name, user: user)
        @long = long
      end

      attr_reader :long

      def action
        :releases
      end

    end

  end
end
