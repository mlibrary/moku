# frozen_string_literal: true

require "thor"
require "fauxpaas"
require "fauxpaas/cli/syslog"
require "fauxpaas/command"

module Fauxpaas
  module CLI

    # Main commands of the cli
    class Main < Thor

      def initialize(*args)
        super(*args)
        @opts = setup
        @invoker = Fauxpaas.invoker
      end

      class_option :verbose,
        aliases: "-v",
        type: :boolean,
        desc: "Show output from system commands",
        default: false,
        required: false

      desc "deploy <instance> [<reference>]",
        "Deploys the instance using the source described by the default branch. " \
        "If a reference is given, that will be deployed instead. " \
        "The reference be a branch, tag, or SHA."
      def deploy(instance_name, reference = nil)
        invoker.add_command(DeployCommand.new(opts.merge(reference: reference)))
      end

      desc "default_branch <instance> [<new_branch>]",
        "Display or set the default branch for the instance"
      def default_branch(instance_name, new_branch = nil)
        command = if new_branch
          SetDefaultBranchCommand.new(opts.merge({new_branch: new_branch}))
        else
          ReadDefaultBranchCommand.new(opts)
        end
        invoker.add_command(command)
      end

      desc "rollback <instance> [<cache>]",
        "Initiate a rollback to the specified cache if specified, or the most " \
          "recent one otherwise. Use with care."
      def rollback(instance_name, cache = "")
        invoker.add_command(RollbackCommand.new(opts.merge({cache: cache})))
      end

      desc "caches <instance>",
        "List cached releases for the instance"
      def caches(instance_name)
        invoker.add_command(CachesCommand.new(opts))
      end

      desc "releases <instance>",
        "List release history for the instance"
      def releases(instance_name)
        invoker.add_command(ReleasesCommand.new(opts))
      end

      desc "restart <instance>",
        "Restart the application for the instance"
      def restart(instance_name)
        invoker.add_command(RestartCommand.new(opts))
      end

      desc "syslog SUBCOMMAND <instance> args...",
        "Interact with system log contents for the instance"
      subcommand "syslog", CLI::Syslog

      private

      attr_reader :opts, :invoker

      def setup
        Fauxpaas.load_settings!(options.symbolize_keys)
        Fauxpaas.initialize!
        options.merge(instance_name: @args.first)
      end
    end

  end
end
