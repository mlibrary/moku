# frozen_string_literal: true

require "thor"
require "fauxpaas"
require "fauxpaas/cli/syslog"
require "fauxpaas/command"

module Fauxpaas
  module CLI

    # Main commands of the cli
    class Main < Thor

      class_option :verbose,
        aliases: "-v",
        type: :boolean,
        desc: "Show output from system commands",
        default: false,
        required: false

      class_option :instance_root,
        desc: "Override location of instances set in settings.yml",
        aliases: "-I",
        type: :string,
        required: false

      class_option :releases_root,
        desc: "Override location of releases set in settings.yml",
        aliases: "-R",
        type: :string,
        required: false

      class_option :deployer_env_root,
        desc: "Override location of capfiles set in settings.yml",
        aliases: "-D",
        type: :string,
        required: false

      desc "deploy <instance>",
        "Deploys the instance's source; by default deploys master. " \
        "Use --reference to deploy a specific revision"
      option :reference,
        type: :string,
        aliases: ["-r", "--branch", "--commit"],
        desc: "The branch or commit to deploy. " \
          "Use default_branch to display or set the default branch."
      def deploy(instance_name)
        setup(instance_name)
        DeployCommand.new(options)
          .validate!
          .run
      end

      desc "default_branch <instance> [<new_branch>]",
        "Display or set the default branch for the instance"
      def default_branch(instance_name, new_branch = nil)
        setup(instance_name)
        if new_branch
          SetDefaultBranchCommand.new(options.merge({new_branch: new_branch}))
        else
          ReadDefaultBranchCommand.new(options)
        end.validate!.run
      end

      desc "rollback <instance> [<cache>]",
        "Initiate a rollback to the specified cache if specified, or the most " \
          "recent one otherwise. Use with care."
      def rollback(instance_name, cache = "")
        setup(instance_name)
        RollbackCommand.new(options.merge({cache: cache}))
          .validate!
          .run
      end

      desc "caches <instance>",
        "List cached releases for the instance"
      def caches(instance_name)
        setup(instance_name)
        CachesCommand.new(options)
          .validate!
          .run
      end

      desc "releases <instance>",
        "List release history for the instance"
      def releases(instance_name)
        setup(instance_name)
        ReleasesCommand.new(options)
          .validate!
          .run
      end

      desc "restart <instance>",
        "Restart the application for the instance"
      def restart(instance_name)
        setup(instance_name)
        RestartCommand.new(options)
          .validate!
          .run
      end

      desc "syslog SUBCOMMAND <instance> args...",
        "Interact with system log contents for the instance"
      subcommand "syslog", CLI::Syslog

      private

      def setup(instance_name)
        @options = options.merge({instance_name: instance_name})
        Fauxpaas.load_settings!(options.symbolize_keys)
        Fauxpaas.initialize!
      end
    end

  end
end
