# frozen_string_literal: true

require "gli"
require "fauxpaas"
require "fauxpaas/command"

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
            Commands::Deploy.new(
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
            Commands::SetDefaultBranch.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user],
              new_branch: args.first
            )
          else
            Commands::ReadDefaultBranch.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          end
          invoker.add_command(command)
        end
      end

      desc "List release history"
      command :releases do |c|
        c.action do |global_options, _options, _args|
          invoker.add_command(
            Commands::Releases.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          )
        end
      end
    end

    private

    attr_reader :invoker

  end
end
