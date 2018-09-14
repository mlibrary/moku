# frozen_string_literal: true

require "pathname"
require "rsync"

RSYNC_OPTIONS = ["-v", "-r", "-l", "-p", "-z"].freeze

namespace :source do
  task :setup do
    set :source_local_path, ENV["SOURCE_PATH"]
  end

  desc "Upload source"
  task upload: [:setup] do
    on roles(:all) do
      Rsync.run("#{fetch(:source_local_path)}/.", "#{fetch(:release_path)}/", RSYNC_OPTIONS)

      # We refrain from chmoding the files here because unshared:upload
      # will do it for us.
    end
  end
end

before "deploy:updating", "source:upload"
