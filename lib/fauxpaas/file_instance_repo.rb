require "fauxpaas/instance"
require "pathname"
require "yaml"

module Fauxpaas

  class FileInstanceRepo
    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    def find(name)
      contents = YAML.load(fs.read(path + name))
      Instance.new(
        name: name,
        deployer_env: contents["deployer_env"]
      )
    end

    def save(instance)
      fs.mkdir_p(path + instance.name)
      fs.write(path + instance.name, YAML.dump("deployer_env" => instance.deployer_env))
    end

    private
    attr_reader :path, :fs


  end

end
