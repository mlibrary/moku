# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

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

      def execute
        string = if long
          LoggedReleases.new(instance.releases).to_s
        else
          LoggedReleases.new(instance.releases).to_short_s
        end

        Fauxpaas.logger.info "\n#{string}"
      end
    end

  end
end
