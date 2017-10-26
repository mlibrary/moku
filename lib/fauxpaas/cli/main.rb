require "thor"
require "pathname"
require "yaml"
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
        Fauxpaas.config = configuration(options)
        instance = Fauxpaas.instance_repo.find(instance_name)
        Fauxpaas.deployer.deploy(instance, reference: options[:reference])
      end

      desc "default_branch <instance> [<new_branch>]",
        "Display or set the default branch for the instance"
      def default_branch(instance_name, new_branch = nil)
        Fauxpaas.config = configuration(options)
        instance = Fauxpaas.instance_repo.find(instance_name)
        if new_branch
          old_branch = instance.default_branch
          instance.default_branch = new_branch
          Fauxpass.instance_repo.save(instance)
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
        Fauxpaas.config = configuration(options)
        instance = Fauxpaas.config.instance_repo.find(instance_name)
        Fauxpaas.deployer.rollback(instance, cache: options[:cache])
      end

      desc "caches <instance>",
        "List cached releases for the instance"
      def caches(instance_name)
        Fauxpaas.config = configuration(options)
        instance = Fauxpaas.instance_repo.find(instance_name)
        puts Fauxpaas.deployer.caches(instance)
      end

      private
      def configuration(opts)
        Configuration.new(config_from_file.merge(Configuration.new(opts)))
      end

      def config_from_file
        if config_path.exist?
          YAML.load(File.read(config_path))
        else
          Configuration.new
        end
      end

      def config_path
        Pathname.new(ENV["HOME"]) + ".fauxpaas.yml"
      end
    end

  end
end
