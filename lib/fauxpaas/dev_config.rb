require "pathname"
require "yaml"
require "fauxpaas/command"
require "fauxpaas/filesystem"

module Fauxpaas

  # Represents the developer configuration, including both files
  # and commands.
  class DevConfig

    def initialize(path, fs = Filesystem.new)
      @path = Pathname.new path
      @fs = fs
    end

    # after_build commands
    # @return [Array<Command>]
    def after_build
      YAML.load(fs.read(after_build_path)).map do |row|
        raise ArgumentError, "One command per line!" if row.size > 1
        Command.new(*row.to_a.first)
      end
    end

    # after_release commands
    # @return [Array<Command>]
    def after_release
      YAML.load(fs.read(after_release_path)).map do |row|
        raise ArgumentError, "One command per line!" if row.size > 1
        Command.new(*row.to_a.first)
      end
    end

    # config file paths
    # @return [Array<Pathname>]
    def files
      fs.children(path) - reserved_files
    end

    # remote repo url
    # @return [String]
    def repo_url
      Fauxpaas.config.dev_repo_url
    end

    # returns local repo path
    def local_repo_path
      path
    end

    private
    attr_reader :path, :fs

    def reserved_files
      [after_build_path, after_release_path]
    end

    def after_release_path
      path + "after_release.yml"
    end

    def after_build_path
      path + "after_build.yml"
    end

  end

end
