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
        "Deploys the instance."
      def deploy(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        Fauxpaas.deployer.deploy(instance, reference: options[:reference])
      end

      desc "default_branch <instance> [<new_branch>]",
        "Display or set the default branch for the instance"
      def default_branch(instance_name, new_branch = nil)
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
    end

  end
end
