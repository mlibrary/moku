require "pathname"
require "yaml"

module Fauxpaas

  class ConfigFiles
    attr_reader :path

    def initialize(path, fs = Filesystem.new)
      @path = path
      @fs = fs
    end

    def list
      var_file.list
    end

    def add(filename, app_path, contents)
      filename = Pathname.new(filename)
      fs.mkdir_p(files_path)
      fs.write(files_path + filename.basename, contents)
      var_file.add(app_path, filename.basename.to_s)
    end

    def move(app_path, new_app_path)
      filename = var_file.fetch(app_path)
      var_file.add(new_app_path, filename)
      var_file.remove(app_path)
    end

    def remove(app_path)
      if filename = var_file.fetch(app_path)
        fs.remove(files_path + filename)
        var_file.remove(app_path)
      end
    end

    private
    attr_reader :fs

    def files_path
      path + "files"
    end

    def var_file
      @var_file ||= VarFile.new(path + "file_map.yml", fs)
    end


  end

end