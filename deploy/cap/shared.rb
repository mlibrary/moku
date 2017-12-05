# frozen_string_literal: true

namespace :shared do
  task :setup do
    set :shared_local_path, ENV["SHARED_CONFIG_PATH"]
    set :shared_remote_path, lambda {
      File.join(shared_path, File.basename(fetch(:shared_local_path)))
    }
    append :linked_files, fetch(:shared_local_path)
  end

  desc "Upload infrastructure config"
  task upload: [:setup] do
    on roles(:all) do
      upload! fetch(:shared_local_path), fetch(:shared_remote_path), recursive: true
    end
  end
end

before "deploy:updating", "shared:upload"
