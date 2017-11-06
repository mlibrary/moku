# frozen_string_literal: true

require "fauxpaas/filesystem"
require "pathname"

module Fauxpaas

  class MemoryFilesystem < Filesystem

    def initialize(files = {})
      @files = files
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

    def mktmpdir
      yield tmpdir
    end

    def tmpdir
      Pathname.new("/some/tmp/dir")
    end

  end

end
