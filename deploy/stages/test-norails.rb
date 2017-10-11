set :application, "test-testing"

# We must use a public repo because our ssh key hasn't been added anywhere
set :repo_url, "https://github.com/dpn-admin/dpn-client.git"
set :branch, "master"
set :deploy_to, File.expand_path(File.join(File.dirname(__FILE__), "../../spec/sandbox/test-testing"))
set :rails_env, "production"
set :assets_prefix, "assets"

set :rbenv_custom_path, "/usr/local/rbenv"

server "localhost",
  roles: %w(app),
  user: ENV["USER"],
  ssh_options: {
    # We use a passwordless key here for ease of use
    keys: [File.join(ENV["HOME"], ".ssh", "id_rsa-fauxpaas")]
  }

