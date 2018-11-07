# frozen_string_literal: true

require "moku"

RSpec.configure do |config|
  config.before(:each) do
    Moku.reset!
    Moku.env = "test"
    Moku.initialize!
    Moku.config.tap do |container|
      container.register(:filesystem) { Moku::MemoryFilesystem.new }
      container.register(:git_runner) { Moku::SpoofedGitRunner.new }
      container.register(:remote_runner) { Moku::FakeRemoteRunner.new }
      container.register(:log_file) { StringIO.new }
      container.register(:logger) {|c| Logger.new(c.log_file, level: :info) }
    end
  end
end
