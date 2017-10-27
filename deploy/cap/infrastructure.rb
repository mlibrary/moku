namespace :infrastructure do
  task :setup do
    set :infrastructure_local_path, ENV['INFRASTRUCTURE_PATH']
    set :infrastructure_remote_path, ->{ File.join(shared_path, File.basename(fetch(:infrastructure_local_path))) }
    append :linked_files, File.basename(ENV['INFRASTRUCTURE_PATH'])
  end

  desc "Upload infrastructure config"
  task :upload => [:setup] do
    on roles(:all) do
      upload! fetch(:infrastructure_local_path), fetch(:infrastructure_remote_path)
    end
  end
end

before "deploy:check:linked_files", "infrastructure:upload"
