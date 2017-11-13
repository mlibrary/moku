# frozen_string_literal: true


set :deploy_to, File.expand_path(File.join(File.dirname(__FILE__), "../../spec/sandbox/test-norails"))

set :rbenv_custom_path, "/usr/local/rbenv"

server "localhost",
  roles: ["app"],
  user: ENV["USER"],
  ssh_options: {
    # We use a passwordless key here for ease of use
    keys: [File.join(ENV["HOME"], ".ssh", "id_rsa-fauxpaas")]
  }
