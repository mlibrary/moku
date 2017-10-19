require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Main < Thor

      desc "deploy <instance>",
        "Deploys the latest revision of the instance's source"
      def deploy(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        Fauxpaas.deployer.deploy(instance)
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
