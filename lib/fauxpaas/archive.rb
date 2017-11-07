require "fauxpaas/git_runner"

module Fauxpaas
  class Archive
    def self.from_hash(hash)
      new(
        hash["url"],
        Object.const_get(hash["git_runner"]).new,
        default_branch: hash["default_branch"]
      )
    end

    def initialize(url, git_runner = GitRunner.new, default_branch: "master")
      @url = url
      @git_runner = git_runner
      @default_branch = default_branch
    end

    attr_reader :url
    attr_accessor :default_branch

    def reference(commitish)
      sha = git_runner.sha(url, "#{commitish}^{}")
      sha ||= git_runner.sha(url, commitish)
      sha ||= commitish
      GitReference.new(url, sha)
    end

    def latest
      reference(default_branch)
    end

    def checkout(reference, &block)
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
        "url" => url,
        "git_runner" => git_runner.class.to_s,
        "default_branch" => default_branch
      }
    end

    private
    attr_reader :git_runner
  end
end
