# frozen_string_literal: true

require "pathname"

namespace :source do
  task :setup do
    set :source_local_path, ENV["SOURCE_PATH"]
  end

  desc "Upload source"
  task upload: [:setup] do
    on roles(:all) do
      Pathname.new(fetch(:source_local_path)).children.each do |path|
        upload! path.to_s, fetch(:release_path), recursive: path.directory?
      end

      # We refrain from chmoding the files here because unshared:upload
      # will do it for us.
    end
  end
end

before "deploy:updating", "source:upload"
