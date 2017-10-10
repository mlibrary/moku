require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Main < Thor

      desc "deploy <instance>",
      "Deploys the latest revision of the instance's source"
      def deploy(instance_name)
        system("cap #{instance_name} deploy")
      end
    end

  end
end
