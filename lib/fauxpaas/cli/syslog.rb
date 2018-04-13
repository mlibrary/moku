# frozen_string_literal: true

require "thor"
require "fauxpaas"
require "fauxpaas/command"

module Fauxpaas
  module CLI

    # Main commands of the cli
    class Syslog < Thor
      def initialize(*args)
        super(*args)
        @opts = setup
        @invoker = Fauxpaas.invoker
      end

      desc "view <instance>",
        "View the system logs for the instance"
      def view(instance_name)
        invoker.add_command(SyslogViewCommand.new(opts))
      end

      desc "grep <instance> pattern",
        "View the system logs for the instance"
      def grep(instance_name, pattern = ".")
        invoker.add_command(SyslogGrepCommand.new(opts.merge({pattern: pattern})))
      end

      desc "follow <instance>",
        "Follow the system logs for the instance"
      def follow(instance_name)
        invoker.add_command(SyslogFollowCommand.new(opts))
      end

      private

      attr_reader :opts, :invoker

      def setup
        Fauxpaas.load_settings!(options.symbolize_keys)
        Fauxpaas.initialize!
        options.merge({
          server: Fauxpaas.server,
          instance_name: @args.first
        })
      end

    end

  end
end
