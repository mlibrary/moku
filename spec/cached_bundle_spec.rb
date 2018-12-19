require "moku/cached_bundle"
require "fileutils"
require "pathname"
require "fakefs/spec_helpers"

module Moku
  RSpec.describe CachedBundle do
    include FakeFS::SpecHelpers
    let(:path) { Pathname.new("/some/path") }
    let(:status) { double(:status, success?: true, error: "") }
    let(:runner) { double(:runner, run: status) }
    let(:cached_bundle) { described_class.new(path: path, runner: runner) }
    let(:artifact) { double(:artifact, path: path) }

    before(:each) do
      FileUtils.mkdir_p path.to_s
      allow(artifact).to receive(:with_env).and_yield
    end

    it "runs the bundle command" do
      expect(runner).to receive(:run).with(/bundle install/)
      cached_bundle.install(artifact)
    end

    it "uses the target's bundle context" do
      expect(artifact).to receive(:with_env)
      cached_bundle.install(artifact)
    end

    it "returns the status" do
      expect(cached_bundle.install(artifact)).to eql(status)
    end

  end
end
