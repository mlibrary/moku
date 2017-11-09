# frozen_string_literal: true

require "fauxpaas/filesystem"
require "pathname"

module Fauxpaas

  class MemoryFilesystem < Filesystem

    def initialize(files = {})
      @files = {}
      files.keys.each do |key|
        @files[key.to_s] = files[key]
      end
    end

    def mkdir_p(path); end

    def write(path, contents)
      @files[path.to_s] = contents
    end

    def remove(path)
      @files.delete(path.to_s)
    end

    def read(path)
      @files[path.to_s]
    end

    def mktmpdir
      yield tmpdir
    end

    def tmpdir
      Pathname.new("/some/tmp/dir")
    end

    def chdir(dir)
      yield
    end

  end

end
