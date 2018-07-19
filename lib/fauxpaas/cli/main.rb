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

      class_option :user,
        desc: "The user running the action, defaults to $USER",
        aliases: "-u",
        type: :string,
        required: true,
        default: ENV["USER"]

      desc "deploy <instance> [<reference>]",
        "Deploys the instance using the source described by the default branch. " \
        "If a reference is given, that will be deployed instead. " \
        "The reference be a branch, tag, or SHA."
      def deploy(_instance_name, reference = nil)
        invoker.add_command(
          DeployCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user],
            reference: reference
          )
        )
      end

      desc "default_branch <instance> [<new_branch>]",
        "Display or set the default branch for the instance"
      def default_branch(_instance_name, new_branch = nil)
        command = if new_branch
          SetDefaultBranchCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user],
            new_branch: new_branch
          )
        else
          ReadDefaultBranchCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user]
          )
        end
        invoker.add_command(command)
      end

      desc "rollback <instance> [<cache>]",
        "Initiate a rollback to the specified cache if specified, or the most " \
          "recent one otherwise. Use with care."
      def rollback(_instance_name, cache = "")
        invoker.add_command(
          RollbackCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user],
            cache: cache
          )
        )
      end

      desc "caches <instance>",
        "List cached releases for the instance"
      def caches(_instance_name)
        invoker.add_command(
          CachesCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user],
          )
        )
      end

      desc "releases <instance>",
        "List release history for the instance"
      def releases(_instance_name)
        invoker.add_command(
          ReleasesCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user],
          )
        )
      end

      desc "restart <instance>",
        "Restart the application for the instance"
      def restart(_instance_name)
        invoker.add_command(
          RestartCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user],
          )
        )
      end

      desc "exec <instance> <role> <bin> [<args>]",
        "Run an arbitrary command."
      long_desc "Run an arbitrary command from the root of the deployed release. " \
        "The command is only run on hosts that match the supplied role. Legal values " \
        "for <role> are app, web, db, or all. For best results, quote the full command."
      option :env, type: :hash, default: {},
        desc: "Specify environment variables. Separate pairs with a space."
      def exec(instance_name, role, *args)
        full = [args.join(" ").split].flatten
        invoker.add_command(
          ExecCommand.new(
            instance_name: opts[:instance_name],
            user: opts[:user],
            env: opts[:env],
            role: role,
            bin: full.first,
            args: full[1..-1]
          )
        )
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
