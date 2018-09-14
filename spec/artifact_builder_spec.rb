# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/artifact_builder"
require "pathname"
require "fakefs/spec_helpers"

module Fauxpaas
  class FakeLazyDir
    attr_reader :path
    def initialize(path)
      @path = path
    end

    def cp(base)
      self.class.new(base)
    end

    def write
      self
    end
  end

  class TestArtifact
    attr_reader :path
    def initialize(path = Pathname.new("/tmp/dir"))
      @path = path
    end
  end

  # require "fauxpaas/artifact_builder"
  RSpec.describe ArtifactBuilder do

    let(:ref_repo) { double(:ref_repo) }
    let(:builder) { described_class.new(ref_repo: ref_repo) }
    let(:builder) do
      described_class.new(
        ref_repo: ref_repo,
        factory: TestArtifact
      )
    end

    describe "#build" do
      include FakeFS::SpecHelpers

      let(:build_path) { Pathname.new "/tmp/dir" }
      let(:source) { double(:source) }
      let(:shared) { double(:shared) }
      let(:deploy) { double(:deploy) }
      let(:unshared) { double(:unshared) }
      let(:signature) { double(:signature, shared: shared, unshared: unshared, source: source) }

      before(:each) do
        FileUtils.mkdir_p(build_path)
        allow(Dir).to receive(:mkbuild_path).and_return(build_path.to_s)
        allow(ref_repo).to receive(:resolve).with(source)
          .and_return(FakeLazyDir.new("/some_source"))
        allow(ref_repo).to receive(:resolve).with(shared)
          .and_return(FakeLazyDir.new("/some_shared"))
        allow(ref_repo).to receive(:resolve).with(unshared)
          .and_return(FakeLazyDir.new("/some_unshared"))
      end

      it "constructs artifacts" do
        expect(builder.build(signature)).not_to be_nil
      end

      it "returns the temporary directory with the artifacts" do
        expect(builder.build(signature).path).to eq(build_path)
      end

      [:source, :shared, :unshared].each do |attr|
        it "resolves the #{attr} repository" do
          expect(ref_repo).to receive(:resolve).with(send(attr))
            .and_return(FakeLazyDir.new("/some_#{attr}"))

          builder.build(signature)
        end
      end
    end
  end
end
