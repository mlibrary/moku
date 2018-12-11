# frozen_string_literal: true

require "moku/task/task"
require "moku/sites/scope"

module Moku
  module Task

    # Create the folder to which we'll deploy
    class CreateStructure < Task
      def call(release)
        release.run(Sites::Scope.all, command(release))
      end

      private

      def command(release)
        "mkdir -p --mode=2775 #{release.deploy_path.parent} && " \
          "mkdir --mode=2775 #{release.deploy_path}"
      end
    end

  end
end
