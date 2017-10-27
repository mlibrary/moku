require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Main < Thor

      option :reference,
        type: :string,
        aliases: ["-r", "--branch", "--commit"],
        desc: "The branch or commit to deploy. " +
          "Use default_branch to display or set the default branch."

      desc "deploy <instance>",
        "Deploys the instance's source; by default deploys master. Use --reference to deploy a specific revision"
      def deploy(instance_name)
        infrastructure_config_path = Fauxpaas.instance_root + instance_name + "infrastructure.yml"
        instance = Fauxpaas.instance_repo.find(instance_name)
        Fauxpaas.deployer.deploy(instance, reference: options[:reference], infrastructure_config_path: infrastructure_config_path)
        Fauxpaas.instance_repo.save(instance)
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
        desc: "The specific cache to rollback to. Defaults to the latest." +
          "Use with care."
      desc "rollback <instance> [<cache>]",
        "Rollsback to the specified cache, or the most recent one."
      def rollback(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        Fauxpaas.deployer.rollback(instance, cache: options[:cache])
      end

      desc "caches <instance>",
        "List cached releases for the instance"
      def caches(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        puts Fauxpaas.deployer.caches(instance)
      end
    end

  end
end
