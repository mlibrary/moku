require "pathname"

module Fauxpaas

  # Represents the developer configuration, including both files
  # and commands.
  class DevConfig

    def initialize(path)
      @path = path
    end

    # returns after_build commands
    def after_build
    end

    # returns after_release commands
    def after_release
    end

    # returns config file paths
    def files
    end

    # returns the remote repo url
    def repo_url
    end

    # returns local repo path
    def local_repo_path
    end

  end

end
