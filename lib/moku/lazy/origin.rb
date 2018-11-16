# frozen_string_literal: true

require "fileutils"

module Moku
  module Lazy

    # Represents a file's source.
    class Origin

      # Return appropriate origin instances for the given sources.
      # @return [Array<Origin>]
      def self.for(*sources)
        registry.find {|candidate| candidate.handles?(*sources) }
          .new(*sources)
      end

      # Used for subclass registration
      def self.registry
        @@registry ||= [] # rubocop:disable Style/ClassVars
      end

      # Used for subclass registration
      def self.register(candidate)
        registry.unshift(candidate)
      end

      # Used for subclass registration
      def self.register_default(candidate)
        registry << candidate
      end

      # Used for subclass registration
      def self.handles?(*_sources)
        false
      end

      # @param sources [Array<Pathname>]
      def initialize(*sources)
        @sources = sources
      end

      # Read the origin's contents
      # @return [String]
      def read
        sources.first.read
      end

      # The extension of the file's path
      # @return [String]
      def extname
        sources.first.extname
      end

      # Whether or not this origin is a merger of two (or more) files.
      # @return [Boolean]
      def merge?
        sources.size > 1
      end

      # The path of the true origin
      # @return [Pathname]
      def start_path
        if sources.first.is_a? Origin
          sources.first.start_path
        else
          sources.first
        end
      end

      # Write the contents of this origin to the destination.
      # @param dest [Pathname]
      def write(dest)
        FileUtils.mkdir_p dest.dirname
        if merge?
          ::File.write(dest, read)
        else
          FileUtils.cp start_path, dest
        end
      end

      private

      attr_reader :sources
    end

  end
end
