# frozen_string_literal: true

require "moku"
require "moku/command/command"
require "moku/pipeline/exec"

module Moku
  module Command

    # Run an arbitrary command
    class Exec < Command
      def initialize(instance_name:, user:, cmd:, scope:)
        super(instance_name: instance_name, user: user)
        @cmd = cmd
        @scope = scope
      end

      def action
        :exec
      end

      def call
        Pipeline::Exec.new(
          cmd: cmd,
          scope: scope,
          release_id: release_id,
          signature: signature
        ).call
      end

      private
      attr_reader :cmd, :scope

      def signature
        logged_release.signature
      end

      def release_id
        logged_release.id
      end

      def logged_release
        instance.releases.first
      end

    end

  end
end
