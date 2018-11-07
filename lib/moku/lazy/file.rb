# frozen_string_literal: true

require "pathname"
require "moku/lazy/origin"

module Moku
  module Lazy

    # A file on disk. The limited set of operations allow
    # manipulation of the file's path through intermediate
    # steps wtihout corresponding disk access or writes. File
    # also allows for merging of two files.
    class File

      # @param path [Pathname]
      def self.for(path)
        return path if path.is_a?(self)

        path = Pathname.new(path)
        new(Origin.for(path), path)
      end

      # @param origin [Origin]
      # @param path [Pathname]
      def initialize(origin, path)
        @origin = origin
        @path = Pathname.new(path)
      end

      attr_reader :origin, :path

      # Read the file's contents
      # @return [String]
      def read
        origin.read
      end

      # Return a new file relative from the given base path.
      # @param base [Pathname]
      # @return [File]
      def relative_from(base)
        File.new(origin, path.relative_path_from(base))
      end

      # Copy the file to a new location
      # @param dest [Pathname]
      # @return [File]
      def cp(dest)
        File.new(origin, Pathname.new(dest))
      end

      # Write this file to disk.
      # @return [File]
      def write
        origin.write(path)
        File.new(Origin.for(path), path)
      end

      # Merge two files together into a new file. This will attempt
      # to merge the two files if possible, otherwise it will overwrite
      # the other's version.
      # @param other [File]
      # @return [File]
      def merge(other)
        File.new(
          Origin.for(origin, other.origin),
          path
        )
      end
    end

  end
end
