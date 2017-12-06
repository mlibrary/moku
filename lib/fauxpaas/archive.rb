# frozen_string_literal: true

require "fauxpaas/git_reference"
require "fauxpaas/components"

module Fauxpaas

  # A version-control archive of some content.  Delegates to the git_runner
  # for actual interaction with the backend vcs.
  class Archive
    def self.from_hash(hash)
      new(
        hash["url"],
        default_branch: hash["default_branch"]
      )
    end

    def initialize(url, default_branch: "master")
      @url = url
      @default_branch = default_branch
    end

    attr_reader :url
    attr_accessor :default_branch

    def reference(commitish)
      return latest if commitish.nil?
      sha = git_runner.sha(url, "#{commitish}^{}")
      sha ||= git_runner.sha(url, commitish)
      sha ||= commitish
      GitReference.new(url, sha)
    end

    def latest
      reference(default_branch)
    end

    def checkout(reference)
      git_runner.safe_checkout(reference.url, reference.reference) do |dir|
        yield dir
      end
    end

    def eql?(other)
      to_hash == other.to_hash
    end
    alias_method :==, :eql?

    def to_hash
      {
        "url"            => url,
        "default_branch" => default_branch
      }
    end

    private

    def git_runner
      Fauxpaas.git_runner
    end

  end
end
