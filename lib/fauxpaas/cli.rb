# frozen_string_literal: true

require "gli"
require "fauxpaas"
require "fauxpaas/kernel_system"
require "fauxpaas/commands"

module Fauxpaas

  # The command-line interface for fauxpaas
  class CLI
    include GLI::App

    def initialize
      program_desc "Fake platform-as-a-service"
      synopsis_format :terminal

      accept(Hash) do |value|
        value.split(",").map do |pair|
          pair.split(":")
        end.to_h
      end

      desc "Show ouput from system commands"
      switch [:v, :verbose]

      desc "The user running the action"
      flag [:u, :user],
        default_value: ENV["USER"],
        arg_name: "USER",
        type: String

      pre do |global_options, _command, _options, args|
        Fauxpaas.load_settings!(global_options)
        Fauxpaas.initialize!
        global_options[:instance_name] = args.shift
        @invoker = Fauxpaas.invoker
      end

      desc "Deploy a release"
      long_desc "Deploys the instance using the source described by the " \
        "default branch. If a reference is given, that will be deployed " \
        "instead. The reference can be a branch, tag, or SHA."
      arg "instance"
      arg "reference", :optional
      command :deploy do |c|
        c.action do |global_options, _options, args|
          invoker.add_command(
            Deploy.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user],
              reference: args.first
            )
          )
        end
      end

      desc "View or set the default branch"
      arg "instance"
      arg "new_branch", :optional
      command :default_branch do |c|
        c.action do |global_options, _options, args|
          command = if args.first
            SetDefaultBranch.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user],
              new_branch: args.first
            )
          else
            ReadDefaultBranch.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          end
          invoker.add_command(command)
        end
      end

      desc "List cached releases"
      arg "instance"
      command :caches do |c|
        c.action do |global_options, _options, _args|
          invoker.add_command(
            Caches.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          )
        end
      end

      desc "List release history"
      command :releases do |c|
        c.action do |global_options, _options, _args|
          invoker.add_command(
            Releases.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          )
        end
      end

      desc "Restart the instance's applications"
      command :releases do |c|
        c.action do |global_options, _options, _args|
          invoker.add_command(
            Restart.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          )
        end
      end

      desc "Run an arbitrary command on matching hosts"
      long_desc "Run an arbitrary command from the root of the deployed " \
        "release. The command is only run on hosts that match the supplied " \
        "role. Legal values for <role> are app, web, db, or all. For best " \
        "results, quote the full command."
      arg "instance"
      arg "role"
      arg "bin"
      arg "arg", [:optional, :multiple]
      command :exec do |c|
        c.flag :env, type: Hash, desc: "Specify environment variables"
        c.action do |global_options, options, args|
          role = args.first
          full = [args[1..-1].join(" ").split].flatten
          invoker.add_command(
            Exec.new(
              instance_name: options[:instance_name],
              user: global_options[:user],
              env: global_options[:env],
              role: role,
              bin: full.first,
              args: full[1..-1]
            )
          )
        end
      end

      desc "Interact with system logs"
      command :syslog do |c|
        c.desc "View the system logs for the instance"
        c.arg "instance"
        c.command :view do |sub|
          sub.action do |global_options, _options, _args|
            Fauxpaas.config.register(:system_runner) { KernelSystem.new }
            invoker.add_command(
              SyslogView.new(
                instance_name: global_options[:instance_name],
                user: global_options[:user]
              )
            )
          end
        end

        c.desc "Grep the system logs for the instance"
        c.arg "instance"
        c.arg "pattern"
        c.command :grep do |sub|
          sub.action do |global_options, _options, args|
            Fauxpaas.config.register(:system_runner) { KernelSystem.new }
            invoker.add_command(
              SyslogGrep.new(
                instance_name: global_options[:instance_name],
                user: global_options[:user],
                pattern: args.first || "."
              )
            )
          end
        end

        c.desc "Follow the system logs for the instance"
        c.arg "instance"
        c.command :follow do |sub|
          sub.action do |global_options, _options, _args|
            Fauxpaas.config.register(:system_runner) { KernelSystem.new }
            invoker.add_command(
              SyslogFollow.new(
                instance_name: global_options[:instance_name],
                user: global_options[:user]
              )
            )
          end
        end
      end
    end

    private

    attr_reader :invoker

  end
end
