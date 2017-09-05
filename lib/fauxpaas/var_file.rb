require "yaml"

module Fauxpaas

  class VarFile

    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    def list
      contents
    end

    def add(key, value)
      contents[key.to_s] = value
    end

    def remove(key)
      contents.delete(key.to_s)
    end

    def write
      fs.write(contents.to_yaml)
    end


    private
    attr_reader :contents, :path, :fs

    def contents
      @contents ||= if fs.exist?(path)
        YAML.load(fs.read(path))
      else
        {}
      end
    end


  end

end