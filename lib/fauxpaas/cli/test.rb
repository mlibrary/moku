require "fauxpaas/configuration"
require "fauxpaas/cli/main"

module Fauxpaas
  module CLI

    class Test < Main
      desc "cap <instance> [<task>]",
        "Runs a capistrano command, with some nice defaults"
      def cap(instance_name, task = "doctor")
        Fauxpaas.config = configuration(options)
        instance = Fauxpaas.instance_repo.find(instance_name)
        instance_capfile_path = Fauxpaas.deployer.send(:capfile_path) + "#{instance.deployer_env}.capfile"
        puts Kernel.system(
          "cap -f #{instance_capfile_path} #{instance.name} #{task} " +
            "BRANCH=#{instance.default_branch}"
        )
      end
    end

  end
end
