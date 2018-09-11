# frozen_string_literal: true

module Fauxpaas
  # A set of files on disk as they will be uploaded to an
  # application server. Pending work on AEIM-1357, AEIM-1361, AEIM-1362,
  # AEIM-1375, AEIM-1363, etc to fully expose the proper shape of this.
  class Artifact
    def initialize(signature:, fs:)
      dir = fs.mktmpdir
      @fs = fs
      @shared_path = extract_ref(signature.shared, dir/"shared")
      @unshared_path = extract_ref(signature.unshared, dir/"unshared")
      @source_path = extract_ref(signature.source, dir/"source")
    end

    def extract_ref(ref, path)
      fs.mkdir_p path
      add_reference(ref, path)
      path
    end

    # This will be refacted in the course of AEIM-1357
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def add_reference(reference, base)
      fs.mkdir_p(base)
      fs.mktmpdir do |dir|
        reference.checkout(dir) do |working_dir|
          working_dir
            .relative_files
            .reject {|path| fs.directory?(path) }
            .map {|file| [working_dir.dir/file, base/file] }
            .each do |src, dest|
              fs.mkdir_p(dest.dirname)
              fs.cp(src, dest)
            end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    attr_reader :source_path, :shared_path, :unshared_path

    private

    attr_reader :fs
  end
end
