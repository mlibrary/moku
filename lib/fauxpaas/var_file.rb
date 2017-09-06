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
    end

    def remove(key)
      contents.delete(key.to_s)
    end

    def write
      # this needs to build the directories...maybe
      fs.write(contents.to_yaml)
    end


    private
    attr_reader :contents, :fs

    def contents
      @contents ||= if fs.exist?(path)
        YAML.load(fs.read(path))
      else
        {}
      end
    end


  end

end