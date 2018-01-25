# frozen_string_literal: true

require "pathname"

module Fauxpaas
  # A version-control archive at a specific point in time.
  class ArchiveReference

    def self.from_hash(hash, runner)
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
    def self.at(url, commitish, runner)
      sha = runner.sha(url, "#{commitish}^{}")
      sha ||= runner.sha(url, commitish)
      sha ||= commitish
      new(url, sha, runner)
    end

    # Create a new instance without resolving the commitish.
    # @param url [String]
    # @param commitish [String]
    def initialize(url, commitish, runner)
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

    # @yield [GitRunner::WorkingDirectory] The directory in which
    #   the content has been checked out.
    def checkout
      runner.safe_checkout(url, commitish) do |working_dir|
        yield working_dir
      end
    end

    def eql?(other)
      url == other.url && commitish == other.commitish
    end

    def to_hash
      {
        "url"       => url,
        "commitish" => commitish,
      }
    end

    private
    attr_reader :runner

  end
end
