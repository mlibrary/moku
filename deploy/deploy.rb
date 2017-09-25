
# config valid only for current version of Capistrano
lock "3.9.1"

DEPLOY_CONF_VAR = "FAUXPAAS_DEPLOY_CONFIG_PATH"

set :deployconf, ->{ 
  raise ArgumentError, "Please set #{DEPLOY_CONF_VAR}" unless ENV[DEPLOY_CONF_VAR]
  YAML.load_file(ENV[DEPLOY_CONF_VAR])  
}

set :application, ->{ fetch(:deployconf)["instance"] }
set :repo_url, ->{ fetch(:deployconf)["source"]["repo"] }
set :branch, ->{ fetch(:deployconf)["source"]["branch"] }
set :deploy_to, ->{ fetch(:deployconf)["release_dir"] }

set :keep_releases, 5
set :local_user, ->{ fetch(:deployconf)["deploy_user"] }
set :pty, false

# We only link files that would be non-sensical to be release-specific.
# This notably does not contain developer configuration.
append :linked_files, "bundle/config", "infrastructure.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Configure capistrano-bundler
set :bundle_roles, :all                                         # this is default
set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) } # this is default
set :bundle_binstubs, -> { shared_path.join('bin') }            # default: nil
set :bundle_gemfile, -> { release_path.join('MyGemfile') }      # default: nil
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
set :rails_env, ->{ fetch(:deployconf)["rails_env"] }
set :migration_role, :app                                     # default: :db, but :app is recommended
set :migration_servers, ->{ primary(fetch(:migration_role)) } # this is default
set :conditionally_migrate, false                             # this is default
set :assets_roles, [:web]                                     # this is default
set :assets_prefix, ->{ fetch(:deployconf)["assets_prefix"] } # default: assets
set :normalize_asset_timestamps, %w{public/images public/javascripts public/stylesheets}
set :keep_assets, 2                                           # default: nil (disabled)

# Setup the other crap we do

set :instance, ->{ Fauxpaas::Instance.new(fetch(:deployconf)["instance"]) }

namespace :fauxpaas do
  namespace :devconf do

    desc "Locally clone the developer config"
    task :download do
      run_locally do
        branch = fetch(:instance).name
        repo_url = fetch(:instance).devconf.repo_url
        local_repo_path = fetch(:instance).devconf.local_devconf_repo
        if Fauxpaas::Filesystem.exist? local_repo_path
          info "Local developer config clone exists."
          `git fetch --git-dir=#{local_repo_path}.git #{repo_url} #{branch}`
        else
          `git clone -b #{branch} --single-branch #{repo_url} #{local_repo_path}`
        end
      end
    end

    desc "Upload files from the developer config"
    task :upload do
      on roles(:fs) do
        fetch(:instance).devconf.files.each do |file|
          upload! file, File.join(release_path, file)
        end
      end
    end

    desc "Run commands in after_build step"
    task :after_build do
      fetch(:instance).devconf.after_build do |command|
        on(command.role.to_sym) do
          within release_path do
            execute command.bin.to_sym, command.options
          end
        end
      end
    end

  end
end

after "deploy:started", "fauxpaas:devconf:download"
before "deploy:updated", "fauxpaas:devconf:upload"
after "deploy:updated", "fauxpaas:devconf:after_build"
