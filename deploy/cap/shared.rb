# frozen_string_literal: true

require "find"
require "pathname"

namespace :shared do
  task :setup do
    set :shared_local_path, ENV["SHARED_CONFIG_PATH"]
    set :shared_remote_path, File.join(fetch(:deploy_to), "shared")
    Find.find(fetch(:shared_local_path))
      .reject{|f| f.match?(/\.\/\.git$/) }
      .map{|f| Pathname.new(f) }
      .reject{|f| f.directory? }
      .map{|f| f.relative_path_from(Pathname.new(fetch(:shared_local_path)))}
      .each{|f| append :linked_files, f.to_s }
  end

  desc "Upload infrastructure config"
  task :upload => [:setup] do
    on roles(:all) do
      Pathname.new(fetch(:shared_local_path)).children.each do |path|
        upload! path.to_s, fetch(:shared_remote_path), recursive: path.directory?
      end
      execute :chmod, "-R", "go-rw", fetch(:shared_remote_path)
    end
  end

  desc "Conditionally invoke the task for deploys but not rollbacks"
  task :try do
    if ENV["SHARED_CONFIG_PATH"]
      invoke "shared:upload"
    end
  end
end

before "deploy:check:linked_files", "shared:try"
