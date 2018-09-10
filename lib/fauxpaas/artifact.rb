# frozen_string_literal: true

module Fauxpaas
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

    attr_reader :source_path, :shared_path, :unshared_path

    private

    attr_reader :fs
  end
end
