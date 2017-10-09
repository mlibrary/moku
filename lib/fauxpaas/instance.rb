require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance
    def initialize(name)
      @app, @stage = name.split("-")
    end

    def path
      Fauxpaas.instance_root + app + stage
    end

    def name
      "#{app}-#{stage}"
    end

    def deploy_config_path
      path + "deploy_config.yml"
    end

    def deploy_conf
      @deploy_conf ||= DeployConfig.new(deploy_config_path)
    end

    def dev_config_path
      path + "dev_config"
    end

    def dev_conf
      @dev_conf ||= DevConfig.new(dev_config_path)
    end

  end

end
