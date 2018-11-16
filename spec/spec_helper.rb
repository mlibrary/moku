# frozen_string_literal: true

require "simplecov"
require "bundler/setup"

# We load these here to for fakefs compat
require "fileutils"
require "find"
require "pathname"
require "pp"
require "pry"
require "stringio"
require "fakefs/spec_helpers"

# Load everything so that we can initialize
require "moku/config"
require_relative "support/fake_remote_runner"
require_relative "support/memory_filesystem"
require_relative "support/spoofed_git_runner"
require_relative "support/have_permissions"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
