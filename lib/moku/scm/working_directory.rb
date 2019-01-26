# frozen_string_literal: true

require "find"
require "pathname"

module Moku
  module SCM

    # Represents a working directory of a checked-out git
    # repository, with a reference to both the checked-out directory
    # and all files within the working directory.
    class WorkingDirectory

      def self.from_path(path)
        files = Find.find(path.to_s)
          .map {|f| Pathname.new(f) }
          .select(&:file?)
          .map {|f| f.relative_path_from(path) }
        new(Pathname.new(path), files)
      end

      # @param dir [Pathname]
      # @param relative_files [Array<Pathname>]
      def initialize(dir, relative_files)
        @dir = dir
        @relative_files = relative_files
      end

      attr_reader :dir, :relative_files

      def real_files
        relative_files.map {|file| dir/file }
      end
    end

  end
end
