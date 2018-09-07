# frozen_string_literal: true

require "capistrano/scm/plugin"
require "fileutils"

module Fauxpaas
  # A capistrano source control manager that does nothing.
  # It's only purpose is to disable the SCM.
  class DirOnlySCM < ::Capistrano::SCM::Plugin

    def set_defaults; end

    # This must define a task (called create_release) by convention
    # that creates the release directory and copies the source code
    # into it.
    def define_tasks
      namespace :fauxpaas do
        task :create_release do
          on release_roles(:all) do
            FileUtils.mkdir_p release_path
          end
        end
        task :set_current_revision do
          set :current_revision, "boomparrot"
        end
      end
    end

    def register_hooks
      after "deploy:new_release_path", "fauxpaas:create_release"
      before "deploy:set_current_revision", "fauxpaas:set_current_revision"
    end

  end
end
