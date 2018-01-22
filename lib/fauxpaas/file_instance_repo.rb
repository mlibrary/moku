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
    def initialize(instances_path, releases_path, fs = Filesystem.new)
      @instances_path = Pathname.new(instances_path)
      @releases_path = Pathname.new(releases_path)
      @fs = fs
    end

    def find(name)
      contents = instance_content(name)
      releases = releases_content(name)
      Instance.new(
        name: name,
        source: ArchiveReference.from_hash(contents["source"]),
        deploy: ArchiveReference.from_hash(contents["deploy"]),
        shared: contents["shared"].map {|h| ArchiveReference.from_hash(h) },
        unshared: contents["unshared"].map {|h| ArchiveReference.from_hash(h) },
        releases: releases.fetch("releases", []).map {|r| LoggedRelease.from_hash(r) }
      )
    end

    def save(instance)
      write_instance(instance)
      write_releases(instance.name, instance.releases)
    end

    private

    attr_reader :instances_path, :releases_path, :fs

    def write_instance(instance)
      fs.mkdir_p(path_to_instance(instance.name).dirname)
      fs.write(path_to_instance(instance.name), YAML.dump(
        "deploy" => instance.deploy.to_hash,
        "source" => instance.source.to_hash,
        "shared" => instance.shared.map(&:to_hash),
        "unshared" => instance.unshared.map(&:to_hash)
      ))
    end

    def write_releases(name, releases)
      fs.mkdir_p(path_to_release(name).dirname)
      fs.write(path_to_release(name), YAML.dump(
        "releases" => releases.map(&:to_hash)
      ))
    end

    def instance_content(name)
      YAML.load(fs.read(path_to_instance(name)))
    end

    def releases_content(name)
      if fs.exists?(path_to_release(name))
        YAML.load(fs.read(path_to_release(name)))
      else
        { "releases" => [] }
      end
    end

    def path_to_instance(name)
      instances_path/name/"instance.yml"
    end

    def path_to_release(name)
      releases_path/"#{name}.yml"
    end

  end

end
