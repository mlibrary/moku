# frozen_string_literal: true

require "moku/plan/plan"
require "moku/task_file"
require "moku/task/build_permissions"
require "moku/task/download_references"
require "moku/task/shell"
require "moku/task/build_docker_image"

module Moku
  module Plan

    # A plan to build a container image. This plan:
    # 1. Downloads the artifact's references
    # 2. Build a Docker image and tags it
    # 3. Aborts on any finish_build.yml steps!
    #
    # Use the factory to bind the instance (for access to app name, uid, gid).
    class DockerBuild < Plan

      def initialize(artifact, instance)
        super(artifact)
        @instance = instance
      end

      protected

      attr_reader :instance

      def main
        [
          Task::DownloadReferences.new,
          Task::BuildDockerImage.new(instance)
        ]
      end

      def finish
        tasks = TaskFile.from_path(task_file_path).map do |task_spec|
          Task::Shell.from_spec(task_spec)
        end

        if tasks.any?
          [FinishBuildUnsupported.new]
        else
          []
        end
      end

      private

      def task_file_path
        target.path/Moku.finish_build_filename
      end

      # No-op task to fail with a message that finish_build is not supported
      # under Docker.
      class FinishBuildUnsupported < Task::Task
        def call(_target)
          Status.failure(
            "Finish-build steps are not supported for Docker instances.\n" \
            "These steps should be done in the Dockerfile."
          )
        end
      end

      # Workaround factory to capture an instance and pass it down to the task,
      # so it can use the instance/app name, uid, and gid.
      class Factory
        attr_reader :instance

        def initialize(instance)
          @instance = instance
        end

        def new(artifact)
          DockerBuild.new(artifact, instance)
        end
      end

    end

  end
end
