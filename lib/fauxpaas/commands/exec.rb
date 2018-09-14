# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

    # Run an arbitrary command
    class Exec < Command
      def initialize(instance_name:, user:, env: {}, role:, bin:, args: [])
        super(instance_name: instance_name, user: user)
        @env = env
        @role = role
        @bin = bin
        @args = args
      end

      attr_reader :env, :role, :bin, :args

      def action
        :exec
      end

      def execute
        report(instance
          .interrogator
          .exec(
            env: env,
            role: role,
            bin: bin,
            args: args.join(" ")
          ))
      end
    end

  end
end
