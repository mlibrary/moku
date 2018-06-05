require "pathname"
require "tmpdir"
require "fileutils"
require "find"

module Fauxpaas

  # Represents a backend over a local repository.
  # @see GitRunner
  class FileRunner
    # @param url [String] This should be a path or Pathname
    # @param commitish [String] A name for the reference.
    # @return [String] The commitish given to this method.
    def sha(url, commitish)
      commitish
    end

    # Checkout (copy) into a temporary directory, and yield the files
    # @param url [String] This should be a path or Pathname
    # @param commitish [String] A name for the reference.
    # @yield [Array<Pathname>] Files contained in the
    #   checked-out repository, including the working directory
    #   itself.
    def safe_checkout(url, commitish, dir)
      cloned_dir = Pathname.new(dir) + "fauxpaas"
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
