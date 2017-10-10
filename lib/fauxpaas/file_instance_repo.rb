require "fauxpaas/instance"
require "pathname"
require "yaml"

module Fauxpaas

  class FileInstanceRepo
    def initialize(fs = Filesystem.new)
      @fs = fs
    end

    def find(name)
      contents = YAML.load(fs.read(path + name + "deploy_config.yml"))
      Instance.new(
        name: name,
        source: contents["source"],
        deploy_user: contents["deploy_user"],
        release_root: contents["release_root"]
      )
    end

    def save(instance)
      fs.mkdir_p(path + instance.name)
      fs.write(YAML.dump(
        name: instance.name,
        source: instance.source,
        deploy_user: instance.deploy_user,
        release_root: instance.release_root
      ))
    end

    private

    def path
      Fauxpaas.instance_root + app + stage
    end

  end

end
