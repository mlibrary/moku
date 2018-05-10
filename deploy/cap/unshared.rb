# frozen_string_literal: true

require "pathname"

namespace :unshared do
  task :setup do
    set :unshared_local_path, ENV["UNSHARED_CONFIG_PATH"]
  end

  desc "Upload unshared config"
  task :upload => [:setup] do
    on roles(:all) do
      Pathname.new(fetch(:unshared_local_path)).children.each do |path|
        upload! path.to_s, fetch(:release_path), recursive: path.directory?
      end

      # Lock down files, but dont follow symlinks into shared dir
      execute :find, "-P", fetch(:release_path), %W(
        -type f
        -perm /g=rw,o=rw
        -exec chmod go-rwx '{}' \\;
      )
    end
  end
end

before "deploy:updating", "unshared:upload"
