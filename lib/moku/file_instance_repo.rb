# frozen_string_literal: true

require "moku/instance"
require "moku/archive_reference"
require "moku/logged_release"
require "moku/instance_busy_error"
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
      locks_path: Moku.locks_root,
      git_runner: Moku.git_runner
    )
      @instances_path = Pathname.new(instances_path)
      @releases_path = Pathname.new(releases_path)
      @branches_path = Pathname.new(branches_path)
      @locks_path = Pathname.new(locks_path)
      @git_runner = git_runner
    end

    def find(name)
      raise ArgumentError unless name
      lock!(name) if Moku.enable_locking
      contents = instance_content(name)
      releases = releases_content(name)
      Instance.new(
        name: name,
        source: instance_from_hash(name, contents),
        deploy: ArchiveReference.from_hash(contents["deploy"], git_runner),
        infrastructure: ArchiveReference.from_hash(
          [contents["infrastructure"]].flatten.first,
          git_runner
        ),
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

    # Obtain an exclusive lock on the lockfile, using the OS's flock feature.
    # The OS will release the lock automatically when the program exits.
    # We intentionally do not remove the lockfile under any circumstances.
    # Idempotent
    def lock!(name)
      return if active_locks.include?(name)

      locks_path.mkpath
      lockfile = File.open(locks_path/name, File::RDWR|File::CREAT, 0o644)
      raise InstanceBusyError unless lockfile.flock(File::LOCK_EX|File::LOCK_NB)

      active_locks << name
    end

    private

    attr_reader :instances_path, :releases_path, :git_runner, :branches_path, :locks_path

    def active_locks
      @active_locks ||= []
    end

    def instance_from_hash(name, hash)
      ArchiveReference.new(
        hash["source"]["url"],
        branch_for(name) || hash["source"]["commitish"],
        git_runner
      )
    end

    def branch_for(name)
      if path_to_branch(name).exist?
        File.read(branches_path/name).strip
      end
    end

    def write_branch(name, branch)
      FileUtils.mkdir_p(path_to_branch(name).dirname)
      File.write(path_to_branch(name), branch)
    end

    def write_releases(name, releases)
      FileUtils.mkdir_p(path_to_release(name).dirname)
      File.write(path_to_release(name), YAML.dump(
        "releases" => releases.map(&:to_hash)
      ))
    end

    def instance_content(name)
      YAML.load(
        ERB.new(File.read(path_to_instance(name))).result
      )
    end

    def releases_content(name)
      if path_to_release(name).exist?
        YAML.load(
          File.read(path_to_release(name))
        )
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
