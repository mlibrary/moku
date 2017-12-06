# frozen_string_literal: true

require "fauxpaas/filesystem"
require "fauxpaas/infrastructure"
require "fauxpaas/archive_reference"
require "yaml"

module Fauxpaas

  # Archive of the infrastructure configuration
  class InfrastructureArchive < ArchiveReference
    def initialize(url, commitish, root_dir, fs: Filesystem.new)
      super(url, commitish, root_dir)
      @fs = fs
    end

    def infrastructure
      checkout do |dir|
        contents = YAML.load(fs.read(dir/"infrastructure.yml"))
        Infrastructure.from_hash(contents)
      end
    end

    private
    attr_reader :fs
  end
end
