require "pathname"
require "fauxpaas/lazy/origin"

module Fauxpaas
  module Lazy

    class File
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

      def read
        origin.read
      end

      # @param base [Pathname]
      # @return [File]
      def relative_from(base)
        File.new(origin, path.relative_path_from(base))
      end

      # @param dest [Pathname]
      # @return [File]
      def cp(dest)
        File.new(origin, Pathname.new(dest))
      end

      # @return [File]
      def write
        origin.write(path)
        File.new(Origin.for(path), path)
      end

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
