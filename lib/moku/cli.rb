# frozen_string_literal: true

require "gli"
require "moku"
require "moku/command"
require "moku/sites/scope"

module Moku

  # The command-line interface for moku
  class CLI # rubocop:disable Metrics/ClassLength
    include GLI::App

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize
      program_desc "A deployment tool"
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
        Moku.load_settings!(global_options)
        Moku.initialize!
        global_options[:instance_name] = args.shift
        @invoker = Moku.invoker
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
            Command::Deploy.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user],
              reference: args.first
            )
          )
        end
      end

      desc "Rollback to a previous release"
      long_desc "This command quickly rolls back to a previously deployed " \
        "release that is still cached on the host servers. You can view the " \
        "list of cached releases via the caches command. If a release id is " \
        "given, this will rollback to that release. Otherwise, it rolls back " \
        "to the most recent release."
      arg "release", :optional
      command :rollback do |c|
        c.action do |global_options, _options, args|
          invoker.add_command(
            Command::Rollback.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user],
              cache_id: args.first
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
            Command::SetDefaultBranch.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user],
              new_branch: args.first
            )
          else
            Command::ReadDefaultBranch.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          end
          invoker.add_command(command)
        end
      end

      desc "List release history"
      command :releases do |c|
        c.desc "Show full SHAs"
        c.switch [:l, :long]
        c.action do |global_options, options, _args|
          invoker.add_command(
            Command::Releases.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user],
              long: options[:long]
            )
          )
        end
      end

      desc "List cached releases"
      command :caches do |c|
        c.desc "Show full SHAs"
        c.switch [:l, :long]
        c.action do |global_options, _options, _args|
          invoker.add_command(
            Command::Caches.new(
              instance_name: global_options[:instance_name],
              user: global_options[:user]
            )
          )
        end
      end

      desc "Run an command on matching hosts"
      long_desc "Run an arbitrary command from the root of the deployed release, with the " \
        "release's environment. Use the flags to specify on which hosts to run. A default " \
        "host is set for each site and one site is designated as primary for the instance. " \
        "The behavior with no flags is to run on the default host at the primary site " \
        "(to simplify operations like database migrations, which will take effect instance-wide)."
      arg "instance"
      arg "cmd", [:multiple]
      command :exec do |c|
        c.example "exec myapp-mystage bundle exec rake db:migrate",
          desc: "Run database migrations on only one host:"
        c.example "exec myapp-mystage -v --host host1,host2,host3 'DEBUG=true bin/status'",
          desc: "Run bin/status on host1, host2, and host3, setting an environment variable " \
          "and printing the output:"
        c.flag [:site, :S], type: Array, desc: "Run on the default host at the specified site(s)"
        c.flag [:host, :H], type: Array, desc: "Run on each of the specified hosts"
        c.switch [:all, :A], negatable: false, desc: "Run on every host for the instance"
        c.switch [:"each-site", :Z], negatable: false, desc: "Run on the default host at every site"
        c.action do |global_options, options, args|
          scope = if options[:site]
            Sites::Scope.site(*options[:site])
          elsif options options[:host]
            Sites::Scope.host(*options[:host])
          elsif options[:"each-site"]
            Sites::Scope.each_site
          elsif options[:all]
            Sites::Scope.all
          else
            Sites::Scope.once
          end

          invoker.add_command(
            Command::Exec.new(
              instance_name: options[:instance_name],
              user: global_options[:user],
              cmd: args.join(" "),
              scope: scope
            )
          )
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    attr_reader :invoker

  end
end
