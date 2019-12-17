# frozen_string_literal: true

require "moku/plan/plan"
require "moku/task_file"
require "moku/task/remote_shell"
require "moku/task/push_docker_image"
require "moku/task/kube_release"

module Moku
  module Plan

    # A basic plan to deploy a Release
    class DockerDeploy < Plan

      def initialize(release, instance)
        super(release)
        @instance = instance
      end

      protected

      attr_reader :instance

      def prepare
        [
          Task::PushDockerImage.new(instance)
        ]
      end

      def main
        TaskFile.from_path(task_file_path).map do |task_spec|
          Task::RemoteShell.from_spec(task_spec)
        end
      end

      def finish
        [
          Task::KubeRelease.new
        ]
      end

      private

      def task_file_path
        target.path/Moku.finish_deploy_filename
      end

      # Workaround factory to capture an instance and pass it down to the task,
      # so it can use the instance/app/image name.
      class Factory
        attr_reader :instance

        def initialize(instance)
          @instance = instance
        end

        def new(release)
          DockerDeploy.new(release, instance)
        end
      end

    end

  end
end
