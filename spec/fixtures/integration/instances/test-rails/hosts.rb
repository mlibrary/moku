# frozen_string_literal: true

require "tmpdir"
require "pathname"

test_deploy_locator = Pathname.new(__FILE__)/"../../../../../sandbox/test_deploy_root"
deploy_to = File.read(test_deploy_locator).strip
`mkdir -p #{deploy_to}`

set :deploy_to, deploy_to

server "localhost",
  roles: ["app"],
  user: ENV["USER"],
  ssh_options: {
    # We use a passwordless key here for ease of use
    keys: [File.join(ENV["HOME"], ".ssh", "id_rsa-fauxpaas")]
  }
