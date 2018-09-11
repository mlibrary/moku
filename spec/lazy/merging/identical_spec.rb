require_relative "../../spec_helper"
require "fauxpaas/lazy/merging/identical"

module Fauxpaas
  RSpec.describe Lazy::Merging::Identical do

    describe "::handles?" do
      it "handles a single source" do
        expect(described_class.handles?(5)).to be true
      end
      it "handles identical sources" do
        expect(described_class.handles?(1,1,1,1)).to be true
      end
      it "does not handle different sources" do
        expect(described_class.handles?(1,2)).to be false
      end
    end

    describe "#extname" do
      let(:nested_origin) { described_class.new(double(:origin, extname: "foo")) }
      let(:path_origin) { described_class.new(Pathname.new("some/foo.txt")) }
      it "returns the extension for Pathname sources" do
        expect(path_origin.extname).to eql(".txt")
      end
      it "returns the extension for Origin sources" do
        expect(nested_origin.extname).to eql("foo")
      end
    end

    describe "#read" do
      let(:source) { double(:source, read: contents) }
      let(:origin) { described_class.new(source) }
      let(:contents) { "somecontent" }
      it "returns the file's contents" do
        expect(origin.read).to eql(contents)
      end
    end

    describe "#merge?" do
      it "is false" do
        expect(described_class.new(1,1).merge?).to be false
      end
    end

  end
end
