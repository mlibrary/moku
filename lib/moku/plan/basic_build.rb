# frozen_string_literal: true

require "moku/plan/plan"
require "moku/task_file"
require "moku/task/bundle"
require "moku/task/download_references"
require "moku/task/build_permissions"
require "moku/task/shell"

module Moku
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
        [
          TaskFile.new(task_file_path).map do |raw_task|
            Task::Shell.new(command: raw_task[:cmd])
          end,
          Task::BuildPermissions.new
        ].flatten
      end

      private

      def task_file_path
        target.path/Moku.finish_build_filename
      end

    end

  end
end
