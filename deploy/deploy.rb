lock "3.9.1"

set :ssh_options, {
  user: "fauxpaas",
  keys: %w(our_key_here),
  forward_agent: false,
  auth_methods: %w(publickey)
}

set :keep_releases, 5
set :local_user, "fauxpaas"
set :pty, false

# We only link files that would be non-sensical to be release-specific.
# This notably does not contain developer configuration.
append :linked_dirs, "bundle", "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Configure capistrano-bundler
set :bundle_roles, :all                                         # this is default
set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) } # this is default
set :bundle_path, -> { shared_path.join('bundle') }             # this is default
set :bundle_without, %w{development test}.join(' ')             # this is default
set :bundle_flags, '--deployment --quiet'                       # this is default
set :bundle_env_variables, {}                                   # this is default
set :bundle_clean_options, ""                                   # this is default
set :bundle_jobs, 4                                             # default: nil

# Configure capistrano-rbenv
#intentionally omit setting :rbenv_ruby
set :rbenv_type, :system
set :rbenv_map_bins, %w{rake gem bundle ruby rails pry}
set :rbenv_custom_path, "/l/local/rbenv"
set :rbenv_prefix, ->{"RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"}
set :rbenv_roles, :all

# Configure capistrano-rails
set :migration_role, :app                                     # default: :db, but :app is recommended
set :migration_servers, ->{ primary(fetch(:migration_role)) } # this is default
set :conditionally_migrate, false                             # this is default
set :assets_roles, [:web]                                     # this is default
set :normalize_asset_timestamps, %w{public/images public/javascripts public/stylesheets}
set :keep_assets, 2                                           # default: nil (disabled)

