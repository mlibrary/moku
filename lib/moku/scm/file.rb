# frozen_string_literal: true

require "pathname"
require "fileutils"
require "moku/scm/working_directory"

module Moku
  module SCM

    # Represents a backend over a local repository.
    # @see Git
    class File
      # @param url [String] This should be a path or Pathname
      # @param commitish [String] A name for the reference.
      # @return [String] The commitish given to this method.
      def sha(_url, commitish)
        commitish
      end

      # Checkout (copy) into a temporary directory, and yield the files
      # @param url [String] This should be a path or Pathname
      # @param commitish [String] A name for the reference.
      # @yield [Array<Pathname>] Files contained in the
      #   checked-out repository, including the working directory
      #   itself.
      def safe_checkout(url, _commitish, dir)
        cloned_dir = Pathname.new(dir) + "moku"
        FileUtils.cp_r url, cloned_dir
        working_directory = WorkingDirectory.from_path(cloned_dir)
        if block_given?
          yield working_directory
        else
          working_directory
        end
      end

    end
  end
end
