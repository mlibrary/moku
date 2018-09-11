# frozen_string_literal: true

module Fauxpaas
  # A set of files on disk as they will be uploaded to an
  # application server. Pending work on AEIM-1361, AEIM-1362,
  # AEIM-1375, AEIM-1363, etc to fully expose the proper shape of this.
  class Artifact
    def initialize(signature:, ref_repo:)
      dir = Pathname.new(Dir.mktmpdir)
      @ref_repo = ref_repo
      @shared_path = extract_ref(signature.shared, dir/"shared")
      @unshared_path = extract_ref(signature.unshared, dir/"unshared")
      @source_path = extract_ref(signature.source, dir/"source")
    end

    attr_reader :source_path, :shared_path, :unshared_path

    private

    attr_reader :ref_repo

    def extract_ref(ref, path)
      ref_repo.resolve(ref)
        .cp(path)
        .write
        .path
    end

  end
end
