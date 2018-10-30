# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/command/command"

module Fauxpaas
  module Command

    # Show the cached releases
    class Caches < Command
      def initialize(instance_name:, user:, long: false)
        super(instance_name: instance_name, user: user)
        @long = long
      end

      attr_reader :long

      def action
        :caches
      end

    end

  end
end
