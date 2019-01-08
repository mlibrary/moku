# frozen_string_literal: true

require "moku/task/task"
require "moku/sites/scope"

module Moku
  module Task

    # Symlink current to the passed, deployed release.
    class SetCurrent < Task

      def call(release)
        release.run(
          Sites::Scope.all,
          "rm -f #{release.app_path} && ln -s $PWD ../../current"
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
