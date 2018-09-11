# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/artifact"

module Fauxpaas
  class FakeWorkingDir
    def initialize(dir, files)
      @dir = dir
      @files = files
    end
    attr_reader :dir
    def relative_files
      @files
    end
  end

  RSpec.describe Artifact do
    let(:source) { double(:source) }
    let(:shared) { double(:shared) }
    let(:deploy) { double(:deploy) }
    let(:unshared) { double(:unshared) }

    let(:runner) { Fauxpaas.git_runner }

    let(:fs) do
      MemoryFilesystem.new(
        runner.tmpdir/"infrastructure.yml" => YAML.dump(a: 1, b: 2),
        runner.tmpdir/"my_shared.yml" => YAML.dump("blahblah")
)
    end

    before(:each) do
      allow(source).to receive(:checkout)
        .and_yield(FakeWorkingDir.new(fs.tmpdir, [Pathname.new("some_source.rb")]))
      allow(unshared).to receive(:checkout)
        .and_yield(FakeWorkingDir.new(fs.tmpdir, [Pathname.new("unshared.yml")]))
      allow(shared).to receive(:checkout)
        .and_yield(FakeWorkingDir.new(fs.tmpdir, [Pathname.new("infrastructure.yml")]))
    end

    let(:signature) { double(:signature, shared: shared, unshared: unshared, source: source) }

    let(:built_release) { described_class.new(signature: signature, fs: fs) }

    it "can be constructed" do
      expect(built_release).not_to be_nil
    end

    [:source, :shared, :unshared].each do |attr|
      describe "#{attr}_path" do
        it "returns the #{attr}_path corresponding to the signature" do
          expect(built_release.public_send(:"#{attr}_path")).to eq(fs.tmpdir/attr.to_s)
        end
      end
    end
  end
end
