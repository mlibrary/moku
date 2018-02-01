# frozen_string_literal: true

require "simplecov"
require "bundler/setup"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset all global state
  config.after(:each) do
    Fauxpaas.methods(false)
      .select { |m| m.match(/=$/) }
      .each { |m| Fauxpaas.public_send(m,nil) }
  end
end
