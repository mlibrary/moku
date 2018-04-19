# frozen_string_literal: true

require "simplecov"
require "bundler/setup"

# We load these here to for fakefs compat
require "pp"
require "pry"
require "stringio"

# Load everything so that we can initialize
require "fauxpaas"
require_relative "support/memory_filesystem"
require_relative "support/spoofed_git_runner"

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
      container.register(:log_file) { StringIO.new }
      container.register(:logger) {|c| Logger.new(c.log_file, level: :info) }
    end
  end
end
