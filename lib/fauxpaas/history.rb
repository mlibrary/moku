module Fauxpaas

  class History

    def initialize(instance)
      @instance = instance
    end

    def list
      `git --no-pager --git-dir=#{instance.path} log --pretty=format: '%h (%ad) %s' --date=local`
    end

    def checkout(sha)
      `git stash`
      `git checkout #{sha}`
      yield instance
      `git checkout -`
      `git stash pop`
    end

    private
    attr_reader :instance
  end

end