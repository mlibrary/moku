require "fauxpaas/cli/main"

module Fauxpaas
  module CLI

    class Test < Main
      desc "cap <instance> [<task>]",
        "Runs a capistrano command, with some nice defaults"
      def cap(instance_name, task = "doctor")
        instance = Fauxpaas.instance_repo.find(instance_name)
        infrastructure_config_path = Fauxpaas.instance_root + instance_name + "infrastructure.yml"
        instance_capfile_path = Fauxpaas.deployer.send(:capfile_path) + "#{instance.deployer_env}.capfile"
        puts Kernel.system(
          "cap -f #{instance_capfile_path} #{instance.name} #{task} " +
            "BRANCH=#{instance.default_branch} " +
            "INFRASTRUCTURE_PATH=#{infrastructure_config_path}"
        )
      end
    end

  end
end
