# frozen_string_literal: true

set :application, "test-rails"

# We must use a public repo because our ssh key hasn't been added anywhere
set :repo_url, "https://github.com/mlibrary/chipmunk.git"
set :deploy_to, File.expand_path(File.join(File.dirname(__FILE__), "../../spec/sandbox/test-rails"))
set :rails_env, "development"
set :assets_prefix, "assets"

set :rbenv_custom_path, "/usr/local/rbenv"

# Changed because we're testing against dev
set :bundle_without, ["test"].join(" ") # this is default
set :bundle_flags, "--deployment --quiet" # this is default

server "localhost",
  roles: ["app"],
  user: ENV["USER"],
  ssh_options: {
    # We use a passwordless key here for ease of use
    keys: [File.join(ENV["HOME"], ".ssh", "id_rsa-fauxpaas")]
  }
