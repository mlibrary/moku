# frozen_string_literal: true

require "fauxpaas/plan/plan"
require "fauxpaas/task_file"
require "fauxpaas/task/create_structure"
require "fauxpaas/task/remote_shell"
require "fauxpaas/task/restart"
require "fauxpaas/task/set_current"
require "fauxpaas/task/upload"

module Fauxpaas
  module Plan

    # A basic plan to deploy a Release
    class BasicDeploy < Plan

      protected

      def prepare
        [
          Task::CreateStructure.new,
          Task::Upload.new
        ]
      end

      def main
        TaskFile.new(task_file_path).map do |raw_task|
          Task::RemoteShell.new(
            command: raw_task["cmd"],
            per: raw_task["per"]
          )
        end
      end

      def finish
        [
          Task::SetCurrent.new,
          Task::Restart.new
        ]
      end

      private

      def task_file_path
        target.path/Fauxpaas.finish_deploy_filename
      end

    end

  end
end
