
module Fauxpaas
  class WorkingDirectory
    # @param dir [Pathname]
    # @param relative_files [Array<Pathname>]
    def initialize(dir, relative_files)
      @dir = dir
      @relative_files = relative_files
    end

    attr_reader :dir, :relative_files

    def real_files
      relative_files.map{|file| dir/file }
    end

  end
end
