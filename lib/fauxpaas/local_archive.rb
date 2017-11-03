require "fauxpaas/archive"
require "fauxpaas/git_reference"

module Fauxpaas
  class LocalArchive < Archive
    register(self)

    def self.handles?(type)
      type == self.to_s
    end

    def to_hash
      super.merge("type" => self.class.to_s)
    end

    def reference(commitish)
      sha = git_runner.rev_parse("#{commitish}^{}")
      sha ||= git_runner.rev_parse(commitish)
      GitReference.new(url, sha)
    end

  end
end
