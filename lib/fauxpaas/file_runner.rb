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
    def safe_checkout(url, commitish)
      Dir.mktmpdir do |dir|
        cloned_dir = Pathname.new(dir) + "fauxpaas"
        FileUtils.cp_r url, cloned_dir
        Dir.chdir(cloned_dir) do
          yield WorkingDirectory.from_path(cloned_dir)
        end
      end
    end

  end
end
