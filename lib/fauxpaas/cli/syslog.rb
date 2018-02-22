# frozen_string_literal: true

require "thor"
require "fauxpaas"
require "fauxpaas/kernel_system"
require "fauxpaas/command"

module Fauxpaas
  module CLI

    # Main commands of the cli
    class Syslog < Thor

      class_option :user,
        desc: "The user running the action, defaults to $USER",
        aliases: "-u",
        type: :string,
        required: true,
        default: ENV["USER"]

      desc "view <instance>",
        "View the system logs for the instance"
      def view(instance_name)
        opts, policy = setup_for(instance_name)
        SyslogViewCommand.new(opts, policy).run
      end

      desc "grep <instance> pattern",
        "View the system logs for the instance"
      def grep(instance_name, pattern = ".")
        opts, policy = setup_for(instance_name)
        SyslogGrepCommand.new(opts.merge({pattern: pattern}), policy).run
      end

      desc "follow <instance>",
        "Follow the system logs for the instance"
      def follow(instance_name)
        opts, policy = setup_for(instance_name)
        SyslogFollowCommand.new(opts, policy).run
      end

      private

      def setup_for(instance_name)
        opts = options.merge({instance_name: instance_name})
        Fauxpaas.load_settings!(opts.symbolize_keys)
        Fauxpaas.initialize!
        Fauxpaas.config.register(:system_runner) { KernelSystem.new }
        policy = Fauxpaas.policy_factory_repo
          .find
          .for(opts[:user], opts[:instance_name])
        [opts, policy]
      end

    end

  end
end
