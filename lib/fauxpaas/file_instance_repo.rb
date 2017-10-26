require "fauxpaas/instance"
require "fauxpaas/filesystem"
require "pathname"
require "yaml"

module Fauxpaas

  class FileInstanceRepo
    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    def find(name)
      contents = YAML.load(fs.read(path + "#{name}.yml"))
      Instance.new(
        name: name,
        deployer_env: contents["deployer_env"],
        default_branch: contents["default_branch"],
        deployments: contents.fetch("deployments",[]).map { |d| Deployment.from_hash(d) }
      )
    end

    def save(instance)
      save_path = path + "#{instance.name}.yml"
      fs.mkdir_p(save_path.dirname)
      fs.write(save_path, YAML.dump(
        "deployer_env" => instance.deployer_env,
        "default_branch" => instance.default_branch,
        "deployments" => instance.deployments.map { |d| d.to_hash }
      ))
    end

    private
    attr_reader :path, :fs

  end

end
