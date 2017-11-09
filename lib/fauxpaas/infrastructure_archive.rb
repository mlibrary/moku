require "fauxpaas/infrastructure"
require "fauxpaas/filesystem"
require "pathname"
require "yaml"

module Fauxpaas
  class InfrastructureArchive < SimpleDelegator
    def initialize(archive, root_dir: Pathname.new(""), fs: Filesystem.new)
      @archive = archive
      @root_dir = root_dir
      @fs = fs
      __setobj__ @archive
    end

    def infrastructure(reference)
      archive.checkout(reference) do |dir|
        path = Pathname.new(dir) + root_dir + "infrastructure.yml"
        Infrastructure.from_hash(YAML.load(fs.read(path)))
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
