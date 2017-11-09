# frozen_string_literal: true

namespace :infrastructure do
  task :setup do
    set :infrastructure_local_path, ENV["INFRASTRUCTURE_CONFIG_PATH"]
    set :infrastructure_remote_path, -> { File.join(shared_path, File.basename(fetch(:infrastructure_local_path))) }
    append :linked_files, fetch(:infrastructure_local_path)
  end

  desc "Upload infrastructure config"
  task upload: [:setup] do
    on roles(:all) do
      upload! fetch(:infrastructure_local_path), fetch(:infrastructure_remote_path)
    end
  end
end

before "deploy:check:linked_files", "infrastructure:upload"
