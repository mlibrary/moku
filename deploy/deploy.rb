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

# Configure capistrano-bundler; required only while we are still running rake
# via Cap, since the assets / migration plugins run system rake otherwise.
# Alternatively, we could use a binstub and put bin/ on the path to ensure
# that the bundle is activated.
set :bundle_roles, :none

# We only link files that would be non-sensical to be release-specific.
# This notably does not contain developer configuration.
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Configure capistrano-rbenv
# intentionally omit setting :rbenv_ruby
set :rbenv_type, :system
set :rbenv_map_bins, ["rake", "gem", "ruby", "rails", "pry"]
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

task :deploy_perms do
  on roles(:all) do
    set :releases_path, File.join(fetch(:deploy_to), "releases")
    execute :chmod, "2775", fetch(:releases_path)
    execute :chmod, "2775", fetch(:release_path)
  end
end
after "deploy:updated", :deploy_perms

load File.join(File.dirname(__FILE__), "cap", "source.rb")
load File.join(File.dirname(__FILE__), "cap", "restart.rb")
load File.join(File.dirname(__FILE__), "cap", "syslog.rb")
load File.join(File.dirname(__FILE__), "cap", "commands.rb")
load File.join(File.dirname(__FILE__), "cap", "assets.rb")

