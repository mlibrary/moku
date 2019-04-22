# frozen_string_literal: true

require "moku"
require "moku/command/command"

module Moku
  module Command

    # Run an arbitrary command
    class Exec < Command
      def initialize(instance_name:, user:, cmd:, scope:)
        super(instance_name: instance_name, user: user)
        @cmd = cmd
        @scope = scope
      end

      attr_reader :cmd, :scope

      def action
        :exec
      end

      def signature
        logged_release.signature
      end

      def release_id
        logged_release.id
      end

      private

      def logged_release
        instance.releases.first
      end

    end

  end
end
