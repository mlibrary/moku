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

    def fetch(key)
      contents[key.to_s]
    end

    def add(key, value)
      contents[key.to_s] = value
      fs.write(path, contents.to_yaml)
    end

    def remove(key)
      if contents.has_key?(key.to_s)
        contents.delete(key.to_s)
        fs.write(path, contents.to_yaml)
      end
    end

    private
    attr_reader :fs

    def contents
      @contents ||= if fs.exists?(path)
        YAML.load(fs.read(path))
      else
        {}
      end
    end


  end

end
