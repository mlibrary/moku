# frozen_string_literal: true

require "fauxpaas/filesystem"
require "pathname"

module Fauxpaas

  class MemoryFilesystem

    def initialize(files = {})
      @files = {}
      files.keys.each do |key|
        @files[key.to_s] = files[key]
      end
    end

    def directory?(path)
      false
    end

    def mkdir_p(path); end

    def cp(original, dest)
      write(dest, read(original))
    end

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
      if block_given?
        yield tmpdir
      else
        tmpdir
      end
    end

    def tmpdir
      Pathname.new("/some/tmp/dir")
    end

    def chdir(dir)
      yield
    end

  end

end
