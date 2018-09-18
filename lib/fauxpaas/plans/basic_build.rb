# frozen_string_literal: true

require "fauxpaas/plans/plan"
require "fauxpaas/task_file"
require "fauxpaas/tasks/download_references"
require "fauxpaas/tasks/bundle"

module Fauxpaas
  module Plans

    # A basic plan to build an Artifact. This plan:
    # 1. Downloads the artifact's references
    # 2. Bundles the gems
    # 3. Runs any steps defined by finish_build.yml
    class BasicBuild < Plan

      protected

      def main
        [
          Tasks::DownloadReferences.new,
          Tasks::Bundle.new
        ]
      end

      def finish
        task_file.tasks
      end

      private

      def task_file_path
        target.path/"finish_build.yml"
      end

      def task_file
        TaskFile.new(task_file_path)
      end
    end

  end
end
