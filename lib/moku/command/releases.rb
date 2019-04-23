# frozen_string_literal: true

require "moku"
require "moku/command/command"
require "moku/pipeline/releases"

module Moku
  module Command

    # Show the releases
    class Releases < Command
      def initialize(instance_name:, user:, long: false)
        super(instance_name: instance_name, user: user)
        @long = long
      end

      def call
        Pipeline::Releases.new(instance: instance, long: long).call
      end

      def action
        :releases
      end

      private
      attr_reader :long

    end

  end
end
