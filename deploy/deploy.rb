# frozen_string_literal: true

lock "~> 3.9.1"

set :deploy_to, ENV["DEPLOY_DIR"] || fetch(:deploy_to)
set :rails_env, ENV["RAILS_ENV"]
set :assets_prefix, ENV["ASSETS_PREFIX"]
set :ssh_options, user: fetch(:stage),
  forward_agent: true,
  auth_methods: ["publickey"],
  keys: [ "/home/faux/.ssh/id_rsa" ]

set :split_token, File.read(File.join(File.dirname(__FILE__), "../.split_token"))

set :application, ENV["APPLICATION"]

set :keep_releases, 5
set :local_user, "faux"
set :pty, false

# We only link files that would be non-sensical to be release-specific.
# This notably does not contain developer configuration.
append :linked_dirs, "bundle", "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Configure capistrano-bundler
set :bundle_roles, :all                                         # this is default
set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) } # this is default
set :bundle_path, -> { shared_path.join("bundle") }             # this is default
set :bundle_without, (["development", "test"] - [ENV["RAILS_ENV"]]).join(" ")
set :bundle_flags, "--deployment"
set :bundle_env_variables, {}                                   # this is default
set :bundle_clean_options, ""                                   # this is default
set :bundle_jobs, 4                                             # default: nil

# Configure capistrano-rbenv
# intentionally omit setting :rbenv_ruby
set :rbenv_type, :system
set :rbenv_map_bins, ["rake", "gem", "bundle", "ruby", "rails", "pry"]
set :rbenv_custom_path, ENV["RBENV_ROOT"]
set :rbenv_prefix, lambda {
  "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} " \
    "#{fetch(:rbenv_path)}/bin/rbenv exec"
}
set :rbenv_roles, :all

# Configure capistrano-rails
set :migration_role, :app # default: :db, but :app is recommended
set :migration_servers, -> { primary(fetch(:migration_role)) } # this is default
set :conditionally_migrate, false                             # this is default
set :assets_roles, [:app, :web]
set :normalize_asset_timestamps, ["public/images", "public/javascripts", "public/stylesheets"]
# Disabled to avoid an overzealous cleanup step in rails 3
set :keep_assets, nil

# local stuff
set :systemd_services, ENV.fetch("SYSTEMD_SERVICES", "").split(":")

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

task :open_public do
  on roles(:all) do
    set :shared_path, File.join(fetch(:deploy_to), "shared")
    set :releases_path, File.join(fetch(:deploy_to), "releases")
    execute :mkdir, "-p", "#{fetch(:shared_path)}/public"
    execute :mkdir, "-p", "#{fetch(:release_path)}/public"
    execute :chmod, "2775", fetch(:shared_path)
    execute :chmod, "2775", fetch(:releases_path)
    execute :chmod, "2775", fetch(:release_path)
    execute :find, "#{fetch(:shared_path)}/public", %W(
      -type d
      -exec chmod 2775 '{}' \\;
    )
    execute :find, "#{fetch(:shared_path)}/public", %W(
      -type f
      -exec chmod 664 '{}' \\;
    )
    execute :find, "#{fetch(:release_path)}/public", %W(
      -type d
      -exec chmod 2775 '{}' \\;
    )
    execute :find, "#{fetch(:release_path)}/public", %W(
      -type f
      -exec chmod 664 '{}' \\;
    )
  end
end

after "deploy:updated", :open_public

load File.join(File.dirname(__FILE__), "cap", "source.rb")
load File.join(File.dirname(__FILE__), "cap", "restart.rb")
load File.join(File.dirname(__FILE__), "cap", "syslog.rb")
load File.join(File.dirname(__FILE__), "cap", "commands.rb")
load File.join(File.dirname(__FILE__), "cap", "assets.rb")

