# frozen_string_literal: true

require "fauxpaas/task/task"

module Fauxpaas
  module Task

    # Symlink current to the passed, deployed release.
    class SetCurrent < Task

      def call(release)
        release.run_per_host(
          "rm -f #{release.app_path}; " \
          "ln -s #{target_path(release)} #{release.app_path}"
        )
      end

      private

      def target_path(release)
        release.deploy_path
          .relative_path_from(release.app_path.dirname)
      end
    end

  end
end
