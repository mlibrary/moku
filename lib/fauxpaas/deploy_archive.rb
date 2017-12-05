# frozen_string_literal: true

require "fauxpaas/filesystem"
require "fauxpaas/deploy_config"
require "fauxpaas/archive_reference"
require "yaml"

module Fauxpaas

  # Archive of the deploy configuration
  class DeployArchive < ArchiveReference
    def initialize(url, commitish, root_dir, fs: Filesystem.new)
      super(url, commitish, root_dir)
      @fs = fs
    end

    def deploy_config
      checkout do |dir|
        contents = YAML.safe_load(fs.read(dir/"deploy.yml"))
        DeployConfig.from_hash(contents)
      end
    end

    private
    attr_reader :fs
  end
end
