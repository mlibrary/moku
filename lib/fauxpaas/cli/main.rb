# frozen_string_literal: true

require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    # Main commands of the cli
    class Main < Thor

      option :reference,
        type: :string,
        aliases: ["-r", "--branch", "--commit"],
        desc: "The branch or commit to deploy. " \
          "Use default_branch to display or set the default branch."

      desc "deploy <instance>",
        "Deploys the instance's source; by default deploys master. " \
        "Use --reference to deploy a specific revision"
      def deploy(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        signature = instance.signature(options[:reference])
        release = instance.release(signature)
        if release.deploy.success?
          instance.log_release(LoggedRelease.new(ENV["USER"], Time.now, signature))
          Fauxpaas.instance_repo.save(instance)
          puts "deploy successful"
        else
          puts "deploy unsuccessful"
        end
      end

      desc "default_branch <instance> [<new_branch>]",
        "Display or set the default branch for the instance"
      def default_branch(instance_name, new_branch = nil)
        instance = Fauxpaas.instance_repo.find(instance_name)
        if new_branch
          old_branch = instance.default_branch
          instance.default_branch = new_branch
          Fauxpaas.instance_repo.save(instance)
          puts "Changed default branch from #{old_branch} to #{new_branch}"
        else
          puts "Default branch: #{instance.default_branch}"
        end
      end

      option :cache,
        type: :string,
        aliases: "-c",
        desc: "The specific cache to rollback to. Defaults to the latest." \
          "Use with care."
      desc "rollback <instance> [<cache>]",
        "Rollsback to the specified cache, or the most recent one."
      def rollback(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        instance
          .interrogator
          .rollback(options[:cache])
      end

      desc "caches <instance>",
        "List cached releases for the instance"
      def caches(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        puts instance
          .interrogator
          .caches
      end

      desc "releases <instance>",
        "List release history for the instance"
      def releases(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        puts instance.releases.map(&:to_s).join("\n")
      end
    end

  end
end
