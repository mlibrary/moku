# frozen_string_literal: true

lock "~> 3.9.1"

set :ssh_options, user: "fauxpaas",
  keys: ["our_key_here"],
  forward_agent: false,
  auth_methods: ["publickey"]

set :split_token, File.read(File.join(File.dirname(__FILE__), "../.split_token"))

set :application, ENV["APPLICATION"]

set :keep_releases, 5
set :local_user, "fauxpaas"
set :pty, false

# We only link files that would be non-sensical to be release-specific.
# This notably does not contain developer configuration.
append :linked_dirs, "bundle", "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Configure capistrano-bundler
set :bundle_roles, :all                                         # this is default
set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) } # this is default
set :bundle_path, -> { shared_path.join("bundle") }             # this is default
set :bundle_without, ["development", "test"].join(" ") # this is default
set :bundle_flags, "--deployment --quiet"                       # this is default
set :bundle_env_variables, {}                                   # this is default
set :bundle_clean_options, ""                                   # this is default
set :bundle_jobs, 4                                             # default: nil

# Configure capistrano-rbenv
# intentionally omit setting :rbenv_ruby
set :rbenv_type, :system
set :rbenv_map_bins, ["rake", "gem", "bundle", "ruby", "rails", "pry"]
set :rbenv_custom_path, "/l/local/rbenv"
set :rbenv_prefix, lambda do
  "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} " \
    "#{fetch(:rbenv_path)}/bin/rbenv exec"
end
set :rbenv_roles, :all

# Configure capistrano-rails
set :migration_role, :app # default: :db, but :app is recommended
set :migration_servers, -> { primary(fetch(:migration_role)) } # this is default
set :conditionally_migrate, false                             # this is default
set :assets_roles, [:web]                                     # this is default
set :normalize_asset_timestamps, ["public/images", "public/javascripts", "public/stylesheets"]
set :keep_assets, 2                                           # default: nil (disabled)

namespace :caches do
  desc "List caches"
  task :list do
    on roles(:all) do
      within fetch(:deploy_to) do
        within "releases" do
          STDERR.puts fetch(:split_token)
          STDERR.puts capture(:ls)
        end
      end
    end
  end
end

namespace :deploy do
  task :setup_vars do
    set :repo_url, ENV["SOURCE_REPO"]
    set :branch, ENV["BRANCH"]
    set :deploy_to, fetch(:deploy_to) || ENV["DEPLOY_DIR"]
    set :rails_env, ENV["RAILS_ENV"]
    set :assets_prefix, ENV["ASSETS_PREFIX"]
  end

  before "deploy:starting", "deploy:setup_vars"
end

load File.join(File.dirname(__FILE__), "cap", "infrastructure.rb")
load File.join(File.dirname(__FILE__), "cap", "restart.rb")
