# frozen_string_literal: true

require "fauxpaas/lazy/file"
require "fauxpaas/lazy/origin"
require "pathname"

module Fauxpaas
  RSpec.describe Lazy::File do
    let(:file) { described_class.new(origin, path) }
    let(:origin) { double(:origin) }
    let(:path) { Pathname.new("some/path.txt") }

    describe "::for" do
      let(:path) { "some/path" }

      before(:each) { allow(Lazy::Origin).to receive(:for).and_return(origin) }

      it "wraps the path in a pathname" do
        expect(described_class.for(path).path).to eql(Pathname.new(path))
      end

      it "creates an instance with origin" do
        expect(described_class.for(path).origin).to eql(origin)
      end

      it "defers to Lazy::Origin.for" do
        expect(Lazy::Origin).to receive(:for).with(Pathname.new(path))
        described_class.for(path)
      end
    end

    describe "#read" do
      let(:origin) { double(:origin, read: "foo\nbar") }

      it "returns the origin's read" do
        expect(file.read).to eql(origin.read)
      end
    end

    describe "#relative_from" do
      let(:base_path) { Pathname.new("some/base/path") }
      let(:path) { base_path/"foo"/"bar"/"baz.txt" }

      it "returns a new instance with the path relative" do
        expect(file.relative_from(base_path).path)
          .to eql(path.relative_path_from(base_path))
      end

      it "does not change the origin" do
        expect(file.relative_from(base_path).origin).to eql(file.origin)
      end
    end

    describe "#cp" do
      let(:new_path) { Pathname.new("hey/a/new/path/foo.txt") }

      it "returns a new instance at the new path" do
        expect(file.cp(new_path).path).to eql(new_path)
      end

      it "does not change the origin" do
        expect(file.cp(new_path).origin).to eql(file.origin)
      end
    end

    describe "#write" do
      let(:origin) { double(:origin, write: true) }
      let(:new_origin) { double(:new_origin) }

      before(:each) { allow(Lazy::Origin).to receive(:for).and_return(new_origin) }

      it "defers to origin#write" do
        expect(origin).to receive(:write).with(path)
        file.write
      end

      it "returns a new instance at the path" do
        expect(file.write.path).to eql(path)
      end

      it "returns a new instance with the new origin" do
        expect(file.write.origin).to eql(new_origin)
      end

      it "correctly calls Lazy::Origin.for" do
        expect(Lazy::Origin).to receive(:for).with(path)
        file.write
      end
    end

    describe "#merge" do
      let(:new_origin) { double(:new_origin) }
      let(:other_origin) { double(:other_origin) }
      let(:other_path) { Pathname.new("another/path/to/a/file.json") }
      let(:other) { described_class.new(other_origin, other_path) }

      before(:each) { allow(Lazy::Origin).to receive(:for).and_return(new_origin) }

      it "returns a new instance at the path" do
        expect(file.merge(other).path).to eql(path)
      end

      it "returns a new instance with the new origin" do
        expect(file.merge(other).origin).to eql(new_origin)
      end

      it "correctly calls Lazy::Origin.for" do
        expect(Lazy::Origin).to receive(:for).with(origin, other_origin)
        file.merge(other)
      end
    end
  end
end
