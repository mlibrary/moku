# frozen_string_literal: true

require "moku/cached_bundle"
require "fileutils"
require "pathname"
require "fakefs/spec_helpers"

module Moku
  RSpec.describe CachedBundle do
    include FakeFS::SpecHelpers
    let(:path) { Pathname.new("/some/path") }
    let(:status) { double(:status, success?: true, error: "") }
    let(:version) { "2.5.0" }
    let(:bundle_path) { path/"bundlepath" }
    let(:artifact) { double(:artifact) }
    let(:cached_bundle) { described_class.new(path) }

    before(:each) do
      FileUtils.mkdir_p path.to_s
      allow(artifact).to receive(:gem_version).and_return(version)
      allow(artifact).to receive(:bundle_path).and_return(bundle_path)
      allow(artifact).to receive(:run).and_return(status)
    end

    it "runs the bundle command" do
      expect(artifact).to receive(:run).with(/bundle install/)
      cached_bundle.install(artifact)
    end

    it "returns the status" do
      expect(cached_bundle.install(artifact)).to eql(status)
    end
  end
end
