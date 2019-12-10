# frozen_string_literal: true

require "moku/plan/plan"
require "moku/task_file"
require "moku/task/remote_shell"
require "moku/task/docker_push"
require "moku/task/kube_release"

module Moku
  module Plan

    # A basic plan to deploy a Release
    class DockerDeploy < Plan

      protected

      def prepare
        [
          Task::DockerPush.new
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

    end

  end
end
