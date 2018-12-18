# frozen_string_literal: true

RSpec.shared_examples "a command" do
  describe "#action" do
    it "returns a symbol" do
      expect(command.action).to be_an_instance_of Symbol
    end
  end

  describe "#authorized?" do
    it "calls out to the auth system" do
      expect(auth).to receive(:authorized?).with(
        user: user,
        entity: instance,
        action: command.action
      )
      command.authorized?
    end
    it "delegates to the auth system" do
      expect(command.authorized?).to eql(auth.authorized?)
    end
  end
end

RSpec.shared_context "when running a command spec" do
  let(:instance_repo) do
    double(
      :instance_repo,
      find: instance,
      save_instance: nil,
      save_releases: nil
    )
  end
  let(:auth) { double(:auth, authorized?: true) }
  let(:instance_name) { "myapp-mystage" }
  let(:user) { "someone" }
  let(:instance) { double(:instance, default_branch: "master") }

  before(:each) do
    Moku.reset!
    Moku.env = "test"
    Moku.initialize!
    Moku.config.tap do |container|
      container.register(:auth) { auth }
      container.register(:instance_repo) { instance_repo }
      container.register(:filesystem) { Moku::MemoryFilesystem.new }
      container.register(:git_runner) { Moku::SpoofedGitRunner.new }
      container.register(:remote_runner) { Moku::FakeRemoteRunner.new }
      container.register(:log_file) { StringIO.new }
      container.register(:logger) {|c| Logger.new(c.log_file, level: :info) }
    end
  end
end
