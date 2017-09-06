require "yaml"

module Fauxpaas

  class VarFile
    attr_reader :path

    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    def list
      contents
    end

    def add(key, value)
      contents[key.to_s] = value
      fs.write(path, contents.to_yaml)
    end

    def remove(key)
      contents.delete(key.to_s)
      fs.write(path, contents.to_yaml)
    end

    private
    attr_reader :fs

    def contents
      @contents ||= if fs.exist?(path)
        YAML.load(fs.read(path))
      else
        {}
      end
    end


  end

end
