# frozen_string_literal: true

module Fauxpaas
  # A set of files on disk as they will be uploaded to an
  # application server. Pending work on AEIM-1361, AEIM-1362,
  # AEIM-1375, AEIM-1363, etc to fully expose the proper shape of this.
  class Artifact
    def initialize(signature:, ref_repo:)
      @path = Pathname.new(Dir.mktmpdir)
      @ref_repo = ref_repo

      # to extract to builder
      add_reference(signature.shared)
      add_reference(signature.unshared)
      add_reference(signature.source)
    end

    attr_reader :path

    private

    attr_reader :ref_repo

    def add_reference(ref)
      ref_repo.resolve(ref)
        .cp(path)
        .write
    end

  end
end
