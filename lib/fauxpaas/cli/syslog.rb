# frozen_string_literal: true

require "thor"
require "fauxpaas"
require "fauxpaas/kernel_system"
require "fauxpaas/command"

module Fauxpaas
  module CLI

    # Main commands of the cli
    class Syslog < Thor

      desc "view <instance>",
        "View the system logs for the instance"
      def view(instance_name)
        setup(instance_name)
        SyslogViewCommand.new(options)
          .validate!
          .run
      end

      desc "grep <instance> pattern",
        "View the system logs for the instance"
      def grep(instance_name, pattern = ".")
        setup(instance_name)
        SyslogGrepCommand.new(options.merge({pattern: pattern}))
          .validate!
          .run
      end

      desc "follow <instance>",
        "Follow the system logs for the instance"
      def follow(instance_name)
        setup(instance_name)
        SyslogFollowCommand.new(options)
          .validate!
          .run
      end

      private

      def setup(instance_name)
        @options = options.merge({instance_name: instance_name})
        Fauxpaas.load_settings!(options.symbolize_keys)
        Fauxpaas.initialize!
        Fauxpaas.config.register(:system_runner) { KernelSystem.new }
      end

    end

  end
end
