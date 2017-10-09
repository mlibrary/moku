require "pathname"
require "yaml"

module Fauxpaas

  # Represents the deploy configuration
  class DeployConfig

    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    # Source repository url
    # @return [String]
    def src_repo_url
      contents["source"]["repo"]
    end

    # Source repository branch
    # @return [String]
    def src_branch
      contents["source"]["branch"]
    end

    # Root directory where releases are deployed
    # I.e. the current release will be release_root/current
    # @return [Pathname]
    def release_root
      Pathname.new(contents["release_root"])
    end

    # The user that will be used to run commands on the
    # remote machines.
    # @return [String]
    def deploy_user
      contents["deploy_user"]
    end

    # Rails environment to use; nearly always "production"
    # @return [String]
    def rails_env
      contents["rails_env"] || "production"
    end

    # Assets prefix
    # @return [String]
    def assets_prefix
      contents["assets_prefix"]
    end

    private
    attr_reader :path, :fs
    def contents
      @contents ||= YAML.load(fs.read(path))
    end

  end

end
