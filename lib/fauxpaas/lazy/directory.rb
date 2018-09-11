require "fauxpaas/lazy/file"
require "find"
require "pathname"

module Fauxpaas
  module Lazy

    class Directory
      def self.for(base_path, files = nil)
        base_path = Pathname.new(base_path)
        files ||= Find.find(base_path)
          .map{|path| Pathname.new(path) }
          .select{|path| path.file? }
        new(base_path, files.map{|path| File.for(path)})
      end

      def initialize(path, files)
        @path = Pathname.new(path)
        @files = files
      end

      attr_reader :path, :files

      def basename
        path.basename
      end

      # @param base [Pathname]
      # @return [Directory]
      def relative_from(base)
        base = Pathname.new(base)
        self.class.new(
          path.relative_path_from(base),
          files.map{|file| file.relative_from(base) }
        )
      end

      def add(file)
        self.class.new(
          path,
          files << file.cp(path/file.path.basename)
        )
      end

      def cp(dest)
        dest = Pathname.new(dest)
        self.class.new(
          dest,
          files.map do |file|
            file.cp(dest/file.relative_from(path).path)
          end
        )
      end

      def write
        ::FileUtils.mkdir_p path
        self.class.new(
          path,
          files.map{|file| file.write }
        )
      end

      def merge(other)
        pairs = Hash.new{|hash, key| hash[key] = [] }
        files.each do |file|
          pairs[file.relative_from(path).path] << file
        end
        other.files.each do |file|
          pairs[file.relative_from(other.path).path] << file
        end

        # We assume that there are only two sources per collision
        self.class.new(
          path,
          pairs.map do |relative_path, files|
            if files.size == 1
              files.first.cp(path/relative_path)
            else
              files.first.merge(files.last)
            end
          end
        )
      end
    end

  end
end
