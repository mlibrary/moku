# frozen_string_literal: true

require "thor"
require "fauxpaas"
require "fauxpaas/cli/syslog"

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

      option :reference,
        type: :string,
        aliases: ["-r", "--branch", "--commit"],
        desc: "The branch or commit to deploy. " \
          "Use default_branch to display or set the default branch."

      desc "deploy <instance>",
        "Deploys the instance's source; by default deploys master. " \
        "Use --reference to deploy a specific revision"
      def deploy(instance_name)
        setup(instance_name)
        signature = instance.signature(options[:reference])
        release = ReleaseBuilder.new(signature).build
        status = release.deploy
        report(status, action: "deploy")
        if status.success?
          instance.log_release(LoggedRelease.new(ENV["USER"], Time.now, signature))
          Fauxpaas.instance_repo.save(instance)
          restart(instance_name)
        end
      end

      desc "default_branch <instance> [<new_branch>]",
        "Display or set the default branch for the instance"
      def default_branch(instance_name, new_branch = nil)
        setup(instance_name)
        if new_branch
          old_branch = instance.default_branch
          instance.default_branch = new_branch
          Fauxpaas.instance_repo.save(instance)
          puts "Changed default branch from #{old_branch} to #{new_branch}"
        else
          puts "Default branch: #{instance.default_branch}"
        end
      end

      desc "rollback <instance> [<cache>]",
        "Initiate a rollback to the specified cache if specified, or the most " \
          "recent one otherwise. Use with care."
      def rollback(instance_name, cache = nil)
        setup(instance_name)
        report(instance.interrogator
          .rollback(instance.source.latest, cache),
          action: "rollback")
      end

      desc "caches <instance>",
        "List cached releases for the instance"
      def caches(instance_name)
        setup(instance_name)
        puts instance
          .interrogator
          .caches
      end

      desc "releases <instance>",
        "List release history for the instance"
      def releases(instance_name)
        setup(instance_name)
        puts instance.releases.map(&:to_s).join("\n")
      end

      desc "restart <instance>",
        "Restart the application for the instance"
      def restart(instance_name)
        setup(instance_name)
        report(instance.interrogator.restart,
          action: "restart")
      end

      desc "syslog SUBCOMMAND <instance> args...",
        "Interact with system log contents for the instance"
      subcommand "syslog", CLI::Syslog

      private

      attr_reader :instance

      def setup(instance_name)
        @instance = Fauxpaas.instance_repo.find(instance_name)
        if options.fetch(:verbose, false)
          Fauxpaas.system_runner = VerboseRunner.new
        end
      end

      def report(status, action: "action")
        if status.success?
          puts "#{action} successful"
        else
          puts "#{action} failed (run again with --verbose for more info)"
        end
      end

    end

  end
end
