require "fauxpaas/archive"
require "fauxpaas/git_reference"

module Fauxpaas
  class RemoteArchive < Archive
    register(self)

    def self.handles?(type)
      type == self.to_s
    end

    def to_hash
      super.merge("type" => self.class.to_s)
    end

    def reference(commitish)
      sha = git_runner.ls_remote(url, "#{commitish}^{}")&.first&.first
      sha ||= git_runner.ls_remote(url, commitish)&.first&.first
      sha ||= commitish
      GitReference.new(url, sha)
    end
  end
end
