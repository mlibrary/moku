# frozen_string_literal: true

require "moku/task/task"
require "moku/status"

module Moku
  module Task

    # Download and merge an artifact's files as defined by its
    # source, shared, and unshared directories.
    class DownloadReferences < Task
      def initialize(ref_repo: Moku.ref_repo)
        @ref_repo = ref_repo
      end

      # @param artifact [Artifact]
      def call(artifact)
        add_reference(artifact.source,   artifact.path)
        add_reference(artifact.shared,   artifact.path)
        add_reference(artifact.unshared, artifact.path)
        Status.success
      end

      private

      attr_reader :ref_repo

      # @param ref [ArchiveReference]
      # @param path [Pathname] Where to install the files
      def add_reference(ref, path)
        ref_repo.resolve(ref)
          .cp(path)
          .write
      end
    end

  end
end
