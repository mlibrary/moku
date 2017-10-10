require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Main < Thor

      desc "deploy <instance>",
      "Deploys the latest revision of the instance's source"
      def deploy(instance_name, target)
        instance = InstanceRepo.find(instance_name)
        DeployedReleaseRepo.create(
          name: instance.name,
          deploy_user: instance.deploy_user,
          release_root: instance.release_root,
          source: instance.source,
        )
      end
    end

  end
end
