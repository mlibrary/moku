# frozen_string_literal: true

require "fauxpaas/filesystem"
require "fauxpaas/instance"
require "fauxpaas/archive_reference"
require "fauxpaas/logged_release"
require "pathname"
require "yaml"

module Fauxpaas

  # Repository for persisting instances to files
  class FileInstanceRepo
    def initialize(path, fs = Filesystem.new)
      @path = Pathname.new(path)
      @fs = fs
    end

    def find(name)
      contents = instance_content(name)
      releases = releases_content(name)
      Instance.new(
        name: name,
        source: ArchiveReference.from_hash(contents["source"]),
        deploy: ArchiveReference.from_hash(contents["deploy"]),
        shared: contents["shared"].map{|h| ArchiveReference.from_hash(h) },
        unshared: contents["unshared"].map{|h| ArchiveReference.from_hash(h) },
        releases: releases.fetch("releases", []).map {|r| LoggedRelease.from_hash(r) }
      )
    end

    def save(instance)
      fs.mkdir_p(instance_path(instance.name).dirname)
      fs.write(instance_path(instance.name), YAML.dump(
        "deploy" => instance.deploy.to_hash,
        "source" => instance.source.to_hash,
        "shared" => instance.shared.map(&:to_hash),
        "unshared" => instance.unshared.map(&:to_hash)
      ))
      fs.write(releases_path(instance.name), YAML.dump(
        "releases" => instance.releases.map(&:to_hash)
      ))
    end

    private

    attr_reader :path, :fs

    def instance_content(name)
      YAML.load(fs.read(instance_path(name)))
    end

    def releases_content(name)
      if fs.exists?(releases_path(name))
        YAML.load(fs.read(releases_path(name)))
      else
        { "releases" => [] }
      end
    end

    def instance_path(name)
      path + name + "instance.yml"
    end

    def releases_path(name)
      path + name + "releases.yml"
    end

  end

end
