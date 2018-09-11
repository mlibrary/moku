# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/artifact"
require "pathname"

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

  RSpec.describe Artifact do
    let(:ref_repo) { double(:ref_repo) }
    let(:tmpdir) { Pathname.new "/tmp/dir" }
    let(:source) { double(:source) }
    let(:shared) { double(:shared) }
    let(:deploy) { double(:deploy) }
    let(:unshared) { double(:unshared) }

    before(:each) do
      allow(Dir).to receive(:mktmpdir).and_return(tmpdir.to_s)
      allow(ref_repo).to receive(:resolve).with(source).and_return(FakeLazyDir.new("/some_source"))
      allow(ref_repo).to receive(:resolve).with(shared).and_return(FakeLazyDir.new("/some_shared"))
      allow(ref_repo).to receive(:resolve).with(unshared).and_return(FakeLazyDir.new("/some_unshared"))
    end

    let(:signature) { double(:signature, shared: shared, unshared: unshared, source: source) }

    let(:built_artifact) { described_class.new(signature: signature, ref_repo: ref_repo) }

    it "can be constructed" do
      expect(built_artifact).not_to be_nil
    end

    [:source, :shared, :unshared].each do |attr|
      describe "#{attr}_path" do
        it "returns the #{attr}_path corresponding to the signature" do
          expect(built_artifact.public_send(:"#{attr}_path")).to eq(tmpdir/attr.to_s)
        end
      end
    end
  end
end
