# frozen_string_literal: true

require "fauxpaas/components/git_runner"
require "pathname"

module Fauxpaas
  # A version-control archive at a specific point in time.
  class ArchiveReference

    DEFAULT_DIR = Pathname.new("")

    def self.from_hash(hash)
      new(
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
      new(url, sha, Pathname.new(root_dir))
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

    # Get a reference to the latest commit for the commitish.
    # The definition of the "latest commit" is reflexive for any
    # commitish that is not a branch--i.e., the latest commit of
    # a specific tag or SHA is the corresponding SHA itself.
    # @return [ArchiveReference]
    def latest
      self.class.at(url, commitish, root_dir)
    end

    # Get a resolved reference to the commitish.
    # When given nil, this will defer to #latest
    # @param commitish [String]
    # @return [ArchiveReference]
    def at(new_commitish)
      return latest unless new_commitish
      self.class.at(url, new_commitish, root_dir)
    end

    # @yield [GitRunner::WorkingDirectory] The directory in which
    #   the content has been checked out.
    def checkout
      Fauxpaas.git_runner.safe_checkout(url, commitish) do |working_dir|
        files = working_dir
          .relative_files
          .select {|file| file.fnmatch?("#{root_dir}/**") }
          .map {|file| file.relative_path_from(root_dir) }
        yield WorkingDirectory.new(working_dir.dir/root_dir, files)
      end
    end

    def eql?(other)
      [:@url, :@commitish, :@root_dir].index do |var|
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
