# frozen_string_literal: true

require "moku/task/task"
require "moku/status"
require "fileutils"

module Moku
  module Task

    # Download and merge an artifact's files as defined by its
    # source, infrastructure, and dev directories.
    class DownloadReferences < Task
      def initialize(ref_repo: Moku.ref_repo)
        @ref_repo = ref_repo
      end

      # @param artifact [Artifact]
      def call(artifact)
        add_reference(artifact.source, artifact.path)
        add_reference(artifact.infrastructure, artifact.path)
        add_reference(artifact.dev, artifact.path)
        Status.success
      end

      private

      attr_reader :ref_repo

      # @param ref [ArchiveReference]
      # @param dest [Pathname] Where to install the files
      def add_reference(ref, dest)
        path = ref_repo.resolve(ref)
        FileUtils.mkdir_p dest
        FileUtils.cp_r("#{path}/.", dest)
      end
    end

  end
end
