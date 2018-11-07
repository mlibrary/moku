# frozen_string_literal: true

require "moku/lazy/file"
require "find"
require "pathname"

module Moku
  module Lazy

    # A directory on disk, which contains all nested files and
    # folders (recursively). The limited set of operations
    # allow manipulation of the directory and its files
    # through intermediate steps without corresponding disk
    # access or writes. Directory also allows for merging
    # of two directories.
    class Directory

      # @param base_path [Pathname] The path of the single, top-level
      #   directory.
      # @param files [Array<Pathname>] Files within the directory
      # @return [Directory]
      def self.for(base_path, files = nil)
        base_path = Pathname.new(base_path)
        files ||= Find.find(base_path)
          .map {|path| Pathname.new(path) }
          .select(&:file?)
        new(base_path, files.map {|path| File.for(path) })
      end

      # @param path [Paathname]
      # @param files [Array<Pathname>]
      def initialize(path, files)
        @path = Pathname.new(path)
        @files = files
      end

      attr_reader :path, :files

      # @return [Pathname] The basename of the path, as defined by
      #   Pathname#basename.
      def basename
        path.basename
      end

      # Return a new directory with all paths relative from the new given
      # base path.
      # @param base [Pathname]
      # @return [Directory]
      def relative_from(base)
        base = Pathname.new(base)
        self.class.new(
          path.relative_path_from(base),
          files.map {|file| file.relative_from(base) }
        )
      end

      # Add a file to the directory
      # @param file [Pathname]
      # @return [Directory]
      def add(file)
        self.class.new(
          path,
          files << file.cp(path/file.path.basename)
        )
      end

      # Copy the directory (and its files) to a new location
      # @param dest [Pathname]
      # @return [Directory]
      def cp(dest)
        dest = Pathname.new(dest)
        self.class.new(
          dest,
          files.map do |file|
            file.cp(dest/file.relative_from(path).path)
          end
        )
      end

      # Write this directory to disk, including copying over all
      # of the files.
      # @return [Directory] A new instance for the created files.
      def write
        ::FileUtils.mkdir_p path
        self.class.new(
          path,
          files.map(&:write)
        )
      end

      # Merge two directories into a new directory. This will attempt
      # to merge files with identical paths if possible, otherwise it
      # will discard other's version.
      # @param other [Directory]
      # @return [Directory]
      def merge(other)
        pairs = Hash.new {|hash, key| hash[key] = [] }
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
