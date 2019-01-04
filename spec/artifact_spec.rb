# frozen_string_literal: true

require "moku/artifact"
require "pathname"
require "fileutils"
require "pp"
require "fakefs/spec_helpers"

module Moku
  RSpec.describe Artifact do
    let(:path) { Pathname.new("/some/path") }
    let(:runner) { double(:runner) }
    let(:version) { "2.4.1" }
    let(:status) { double(:status, success?: true, output: "#{version}\n") }
    let(:signature) do
      double(
        :signature,
        deploy: double(:deploy),
        source: double(:source),
        shared: double(:shared),
        unshared: double(:unshared)
      )
    end
    let(:artifact) do
      described_class.new(
        path: path,
        signature: signature,
        runner: runner
      )
    end

    before(:each) do
      allow(runner).to receive(:run).with(a_string_matching("rbenv local"))
        .and_return(status)
    end

    it { expect(artifact.path).to eql(path) }
    it { expect(artifact.source).to eql(signature.source) }
    it { expect(artifact.shared).to eql(signature.shared) }
    it { expect(artifact.unshared).to eql(signature.unshared) }

    describe "#gem_version" do
      include FakeFS::SpecHelpers
      before(:each) { FileUtils.mkdir_p artifact.path }

      context "when version is an alias" do
        let(:version) { "2.4" }

        it { expect(artifact.gem_version).to eql("2.4.0") }
      end

      context "when version is full" do
        let(:version) { "2.5.3" }

        it { expect(artifact.gem_version).to eql("2.5.0") }
      end
    end

    describe "#bundle_path" do
      include FakeFS::SpecHelpers
      before(:each) { FileUtils.mkdir_p artifact.path }

      let(:version) { "2.5.3" }
      let(:expected_path) { path/"vendor"/"bundle"/"ruby"/"2.5.0" }

      it "returns the path" do
        expect(artifact.bundle_path).to eql(expected_path)
      end

      it "makes the path" do
        expect { artifact.bundle_path }
          .to change(expected_path, :exist?)
          .from(false)
          .to(true)
      end
    end
  end
end
