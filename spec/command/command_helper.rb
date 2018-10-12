# frozen_string_literal: true

require "fauxpaas"

RSpec.configure do |config|
  config.before(:each) do
    Fauxpaas.reset!
    Fauxpaas.env = "test"
    Fauxpaas.initialize!
    Fauxpaas.config.tap do |container|
      container.register(:filesystem) { Fauxpaas::MemoryFilesystem.new }
      container.register(:git_runner) { Fauxpaas::SpoofedGitRunner.new }
      container.register(:remote_runner) { Fauxpaas::FakeRemoteRunner.new }
      container.register(:log_file) { StringIO.new }
      container.register(:logger) {|c| Logger.new(c.log_file, level: :info) }
    end
  end
end
