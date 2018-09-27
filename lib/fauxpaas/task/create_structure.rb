# frozen_string_literal: true

require "fauxpaas/task/task"

module Fauxpaas
  module Task

    # Create the folder to which we'll deploy
    class CreateStructure < Task
      def call(release)
        release.run_per_host("mkdir -p #{release.deploy_path}")
      end
    end

  end
end
