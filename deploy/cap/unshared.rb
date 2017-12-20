# frozen_string_literal: true

namespace :unshared do
  task :setup do
    set :unshared_local_path, ENV["UNSHARED_CONFIG_PATH"]
    set :unshared_remote_path, lambda {
      File.join(release_path, File.basename(fetch(:unshared_local_path)))
    }
  end

  desc "Upload infrastructure config"
  task upload: [:setup] do
    on roles(:all) do
      upload! fetch(:unshared_local_path), fetch(:unshared_remote_path), recursive: true
    end
  end
end

before "deploy:updating", "unshared:upload"
