# frozen_string_literal: true

require "fauxpaas/instance"
require "fauxpaas/filesystem"
require "fauxpaas/release"
require "pathname"
require "yaml"

module Fauxpaas

  # Repository for persisting instances to files
  class FileInstanceRepo
    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    def find(name)
      contents = YAML.load(fs.read(instance_path(name)))
      Instance.new(
        name: name,
        source: RemoteArchive.new(
          contents["source"]["url"],
          default_branch: contents["source"]["default_branch"]
        ),
        deploy_config: DeployConfig.new(
          deployer_env: contents["deploy"]["deployer_env"],
          assets_prefix: contents["deploy"]["assets_prefix"],
          deploy_dir: contents["deploy"]["deploy_dir"],
          rails_env: contents["deploy"]["rails_env"]
        ),
        releases: contents.fetch("releases", []).map {|r| Release.from_hash(r) }
      )
    end

    def save(instance)
      fs.mkdir_p(instance_path(instance.name))
      fs.write(instance_path(instance.name), YAML.dump(
        "deploy" => {
          "deployer_env" => instance.deployer_env,
          "assets_prefix" => instance.assets_prefix,
          "deploy_dir" => instance.deploy_dir,
          "rails_env" => instance.rails_env
        },
        "source" => {
          "default_branch" => instance.default_branch,
          "url" => instance.source_repo,
        },
        "releases" => instance.releases.map(&:to_hash)
      ))
    end

    private

    attr_reader :path, :fs

    def instance_path(name)
      path + name + "instance.yml"
    end

  end

end
