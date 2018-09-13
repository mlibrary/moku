# frozen_string_literal: true

require "tmpdir"
require "pathname"

deploy_to = File.join(Dir.tmpdir, "fauxpaas", "sandbox", "test-rails")
`mkdir -p #{deploy_to}`

set :deploy_to, deploy_to

server "localhost",
  roles: ["app"],
  user: ENV["USER"],
  ssh_options: {
    # We use a passwordless key here for ease of use
    keys: [File.join(ENV["HOME"], ".ssh", "id_rsa-fauxpaas")]
  }
