# frozen_string_literal: true

require "moku/filesystem"
require "moku/instance"
require "moku/archive_reference"
require "moku/logged_release"
require "erb"
require "pathname"
require "yaml"

module Moku

  # Repository for persisting instances to files
  class FileInstanceRepo
    def initialize(
      instances_path: Moku.instance_root,
      releases_path: Moku.releases_root,
      branches_path: Moku.branches_root,
      filesystem: Moku.filesystem,
      git_runner: Moku.git_runner
    )
      @instances_path = Pathname.new(instances_path)
      @releases_path = Pathname.new(releases_path)
      @branches_path = Pathname.new(branches_path)
      @filesystem = filesystem
      @git_runner = git_runner
    end

    def find(name)
      contents = instance_content(name)
      releases = releases_content(name)
      Instance.new(
        name: name,
        source: instance_from_hash(name, contents),
        deploy: ArchiveReference.from_hash(contents["deploy"], git_runner),
        infrastructure: ArchiveReference.from_hash([contents["infrastructure"]].flatten.first, git_runner),
        dev: ArchiveReference.from_hash([contents["dev"]].flatten.first, git_runner),
        releases: releases.fetch("releases", []).map {|r| LoggedRelease.from_hash(r) }
      )
    end

    def save_releases(instance)
      write_releases(instance.name, instance.releases)
    end

    def save_instance(instance)
      write_branch(instance.name, instance.default_branch)
    end

    private

    attr_reader :instances_path, :releases_path, :filesystem, :git_runner, :branches_path

    def instance_from_hash(name, hash)
      ArchiveReference.new(
        hash["source"]["url"],
        branch_for(name) || hash["source"]["commitish"],
        git_runner
      )
    end

    def branch_for(name)
      if filesystem.exists?(path_to_branch(name))
        filesystem.read(branches_path/name).strip
      end
    end

    def write_branch(name, branch)
      filesystem.mkdir_p(path_to_branch(name).dirname)
      filesystem.write(path_to_branch(name), branch)
    end

    def write_releases(name, releases)
      filesystem.mkdir_p(path_to_release(name).dirname)
      filesystem.write(path_to_release(name), YAML.dump(
        "releases" => releases.map(&:to_hash)
      ))
    end

    def instance_content(name)
      YAML.load(ERB.new(filesystem.read(path_to_instance(name))).result)
    end

    def releases_content(name)
      if filesystem.exists?(path_to_release(name))
        YAML.load(filesystem.read(path_to_release(name)))
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

    def path_to_branch(name)
      branches_path/name
    end

  end

end
