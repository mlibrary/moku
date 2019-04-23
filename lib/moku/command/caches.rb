# frozen_string_literal: true

require "moku"
require "moku/command/command"
require "moku/pipeline/caches"

module Moku
  module Command

    # Show the cached releases
    class Caches < Command
      def initialize(instance_name:, user:, long: false)
        super(instance_name: instance_name, user: user)
        @long = long
      end

      def call
        Pipeline::Caches.new(instance: instance, long: long).call
      end

      def action
        :caches
      end

      private

      attr_reader :long

    end

  end
end
