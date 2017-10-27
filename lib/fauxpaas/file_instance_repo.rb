require "fauxpaas/instance"
require "fauxpaas/filesystem"
require "fauxpaas/release"
require "pathname"
require "yaml"

module Fauxpaas

  class FileInstanceRepo
    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    def find(name)
      contents = YAML.load(fs.read(instance_path(name)))
      Instance.new(
        name: name,
        deployer_env: contents["deployer_env"],
        default_branch: contents["default_branch"],
        releases: contents.fetch("releases",[]).map { |r| Release.from_hash(r) }
      )
    end

    def save(instance)
      fs.mkdir_p(instance_path(instance.name))
      fs.write(instance_path(instance.name), YAML.dump(
        "deployer_env" => instance.deployer_env,
        "default_branch" => instance.default_branch,
        "releases" => instance.releases.map { |d| d.to_hash }
      ))
    end

    private
    attr_reader :path, :fs

    def instance_path(name)
      path + name + "instance.yml"
    end

  end

end
