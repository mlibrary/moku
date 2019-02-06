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
          "rm -f #{release.app_path} && ln -s #{release.deploy_path} #{release.app_path}"
        )
      end

    end

  end
end
