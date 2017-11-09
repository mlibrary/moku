require "fauxpaas/filesystem"
require "fauxpaas/deploy_config"
require "pathname"
require "yaml"

module Fauxpaas
  class DeployArchive < SimpleDelegator
    def initialize(archive, root_dir: Pathname.new(""), fs: Filesystem.new)
      @archive = archive
      @root_dir = root_dir
      @fs = fs
      __setobj__ @archive
    end

    def deploy_config(reference)
      archive.checkout(reference) do |dir|
        path = Pathname.new(dir) + root_dir + "deploy.yml"
        contents = YAML.load(fs.read(path))
        DeployConfig.from_hash(contents)
      end
    end

    def to_hash
      archive.to_hash
        .merge("root_dir" => root_dir.to_s)
    end

    private
    attr_reader :archive, :root_dir, :fs
  end
end
