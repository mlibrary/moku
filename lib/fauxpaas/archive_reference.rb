# frozen_string_literal: true

require "fauxpaas/components/git_runner"
require "pathname"

module Fauxpaas
  # A version-control archive at a specific point in time.
  class ArchiveReference

    DEFAULT_DIR = Pathname.new("")

    def self.from_hash(hash)
      ArchiveReference.new(
        hash["url"],
        hash["commitish"],
        hash.fetch("root_dir", DEFAULT_DIR)
      )
    end

    # Create a new instance, and interface with the backend
    # to resolve the commitish.
    # @param url [String]
    # @param commitish [String]
    # @param root_dir [Pathname] The directory at which this archive
    #   begins. For most repositories, this is the root directory.
    # @return [ArchiveReference]
    def self.at(url, commitish, root_dir = DEFAULT_DIR)
      sha = Fauxpaas.git_runner.sha(url, "#{commitish}^{}")
      sha ||= Fauxpaas.git_runner.sha(url, commitish)
      sha ||= commitish
      ArchiveReference.new(url, sha, Pathname.new(root_dir))
    end

    # Create a new instance without resolving the commitish.
    # @param url [String]
    # @param commitish [String]
    # @param root_dir [Pathname] The directory at which this archive
    #   begins. For most repositories, this is the root directory.
    def initialize(url, commitish, root_dir = DEFAULT_DIR)
      @url = url
      @commitish = commitish
      @root_dir = Pathname.new(root_dir)
    end

    attr_reader :url, :commitish

    # Get a reference to the latest commit for the commitish,
    # which may be the commitish itself.
    # @return [ArchiveReference]
    def latest
      ArchiveReference.at(url, commitish, root_dir)
    end

    # Get a resolved reference to the commitish.
    # @param commitish [String]
    # @return [ArchiveReference]
    def at(new_commitish)
      return latest unless new_commitish
      ArchiveReference.at(url, new_commitish, root_dir)
    end

    # @yield [GitRunner::WorkingDirectory] The directory in which
    #   the content has been checked out.
    def checkout
      Fauxpaas.git_runner.safe_checkout(url, commitish) do |dir|
        yield dir/root_dir
      end
    end

    def eql?(other)
      instance_variables.index do |var|
        instance_variable_get(var) != other.instance_variable_get(var)
      end.nil?
    end

    def to_hash
      {
        "url"       => url,
        "commitish" => commitish,
        "root_dir"  => root_dir.to_s
      }
    end

    private
    attr_reader :root_dir

  end
end
