# frozen_string_literal: true

require "pathname"

module Moku
  # A version-control archive at a specific point in time.
  class ArchiveReference

    def self.from_hash(hash, runner = Moku.git_runner)
      new(
        hash["url"],
        hash["commitish"],
        runner
      )
    end

    # Create a new instance, and interface with the backend
    # to resolve the commitish.
    # @param url [String]
    # @param commitish [String]
    # @return [ArchiveReference]
    def self.at(url, commitish, runner = Moku.git_runner)
      sha = runner.sha(url, "#{commitish}^{}")
      sha ||= runner.sha(url, commitish)
      sha ||= commitish
      new(url, sha, runner)
    end

    # Create a new instance without resolving the commitish.
    # @param url [String]
    # @param commitish [String]
    def initialize(url, commitish, runner = Moku.git_runner)
      @url = url
      @commitish = commitish
      @runner = runner
    end

    attr_reader :url, :commitish

    # Get a reference to the latest commit for the commitish.
    # The definition of the "latest commit" is reflexive for any
    # commitish that is not a branch--i.e., the latest commit of
    # a specific tag or SHA is the corresponding SHA itself.
    # @return [ArchiveReference]
    def latest
      self.class.at(url, commitish, runner)
    end

    # Get a resolved reference to the commitish.
    # When given nil, this will defer to #latest
    # @param commitish [String]
    # @return [ArchiveReference]
    def at(new_commitish)
      return latest unless new_commitish

      self.class.at(url, new_commitish, runner)
    end

    # Get a reference to the branch without resolving it.
    # No checks are performed against the paramater
    # @param new_branch [String] the branch name
    def branch(new_branch)
      self.class.new(url, new_branch, runner)
    end

    def eql?(other)
      url == other.url && commitish == other.commitish
    end

    def to_hash
      {
        "url"       => url,
        "commitish" => commitish
      }
    end

    private

    attr_reader :runner

  end
end
