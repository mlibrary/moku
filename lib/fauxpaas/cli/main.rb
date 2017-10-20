require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Main < Thor

      option :branch,
          type: :string,
          default: "master",
          desc: "The branch or revision to deploy"

      desc "deploy <instance>",
        "Deploys the instance's source; by default deploys master. Use --branch to deploy a specific revision"
      def deploy(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        Fauxpaas.deployer.deploy(instance,branch: :branch)
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
