# frozen_string_literal: true

require "simplecov"
require "bundler/setup"
require "fauxpaas"
require_relative "support/memory_filesystem"
require_relative "support/spoofed_git_runner"

def resolve_path(raw_path)
  Pathname.new(raw_path).tap do |path|
    if path.relative?
      Fauxpaas.root/path
    else
      path
    end
  end
end


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Fauxpaas.reset!
    Fauxpaas.env = "test"
    Fauxpaas.initialize!
    Fauxpaas.config.tap do |container|
      container.register(:filesystem) { Fauxpaas::MemoryFilesystem.new }
      container.register(:git_runner) { Fauxpaas::SpoofedGitRunner.new }
      container.register(:instance_root) { resolve_path(Fauxpaas.settings.instance_root) }
      container.register(:releases_root) { resolve_path(Fauxpaas.settings.releases_root) }
      container.register(:deployer_env_root) { resolve_path(Fauxpaas.settings.deployer_env_root) }
    end
  end

end
