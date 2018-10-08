# frozen_string_literal: true

require "fauxpaas/task/task"
require "fauxpaas/status"

module Fauxpaas
  module Task

    # Download and merge an artifact's files as defined by its
    # source, shared, and unshared directories.
    class DownloadReferences < Task
      def initialize(ref_repo: Fauxpaas.ref_repo)
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

      def add_reference(ref, path)
        ref_repo.resolve(ref)
          .cp(path)
          .write
      end
    end

  end
end
