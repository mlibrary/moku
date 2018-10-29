# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/command/command"

module Fauxpaas
  module Command

    # Run an arbitrary command
    class Exec < Command
      def initialize(instance_name:, user:, cmd:, per:)
        super(instance_name: instance_name, user: user)
        @cmd = cmd
        @per = per
      end

      attr_reader :cmd, :per

      def action
        :exec
      end

      def signature
        instance.releases.first.signature
      end

    end

  end
end
