# frozen_string_literal: true

require "fauxpaas/plan/plan"
require "fauxpaas/task_file"
require "fauxpaas/task/bundle"
require "fauxpaas/task/download_references"
require "fauxpaas/task/shell"

module Fauxpaas
  module Plan

    # A basic plan to build an Artifact. This plan:
    # 1. Downloads the artifact's references
    # 2. Bundles the gems
    # 3. Runs any steps defined by finish_build.yml
    class BasicBuild < Plan

      protected

      def main
        [
          Task::DownloadReferences.new,
          Task::Bundle.new
        ]
      end

      def finish
        TaskFile.new(task_file_path).map do |raw_task|
          Task::Shell.new(raw_task["cmd"])
        end
      end

      private

      def task_file_path
        target.path/Fauxpaas.finish_build_filename
      end

    end

  end
end
