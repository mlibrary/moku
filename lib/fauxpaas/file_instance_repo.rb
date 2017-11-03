# frozen_string_literal: true

require "fauxpaas/filesystem"
require "fauxpaas/instance"
require "fauxpaas/archive"
require "fauxpaas/local_archive"
require "fauxpaas/remote_archive"
require "fauxpaas/logged_release"
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
        source_archive: Archive.from_hash(contents["source"]),
        deploy_archive: Archive.from_hash(contents["deploy"]),
        infrastructure_archive: Archive.from_hash(contents["infrastructure"]),
        releases: contents.fetch("releases", []).map {|r| LoggedRelease.from_hash(r) }
      )
    end

    def save(instance)
      fs.mkdir_p(instance_path(instance.name))
      fs.write(instance_path(instance.name), YAML.dump(
        "deploy" => instance.deploy_archive.to_hash,
        "source" => instance.source_archive.to_hash,
        "infrastructure" => instance.infrastructure_archive.to_hash,
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
