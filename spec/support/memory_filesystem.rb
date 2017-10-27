# frozen_string_literal: true

require "fauxpaas/filesystem"

module Fauxpaas

  class MemoryFilesystem < Filesystem

    def initialize
      @files = {}
    end

    def mkdir_p(path); end

    def write(path, contents)
      @files[path] = contents
    end

    def remove(path)
      @files.delete(path)
    end

    def read(path)
      @files[path]
    end

  end

end
