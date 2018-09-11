require "fileutils"

module Fauxpaas
  module Lazy

    class Origin
      def self.for(*sources)
        registry.find {|candidate| candidate.handles?(*sources) }
          .new(*sources)
      end

      def self.registry
        @@registry ||= []
      end

      def self.register(candidate)
        registry.unshift(candidate)
      end

      def self.register_default(candidate)
        registry << candidate
      end

      def self.handles?(*sources)
        false
      end

      # @param sources [Array<Path>]
      def initialize(*sources)
        @sources = sources
      end

      def read
        sources.first.read
      end

      def extname
        sources.first.extname
      end

      def is_merge?
        sources.size > 1
      end

      def start_path
        if sources.first.is_a? Origin
          sources.first.start_path
        else
          sources.first
        end
      end

      def write(dest)
        FileUtils.mkdir_p dest.dirname
        if is_merge?
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
