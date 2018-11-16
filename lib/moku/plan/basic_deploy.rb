# frozen_string_literal: true

require "moku/plan/plan"
require "moku/task_file"
require "moku/task/create_structure"
require "moku/task/remote_shell"
require "moku/task/restart"
require "moku/task/set_current"
require "moku/task/upload"

module Moku
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
        target.path/Moku.finish_deploy_filename
      end

    end

  end
end
