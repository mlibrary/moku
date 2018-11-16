# frozen_string_literal: true

require "moku/lazy/origin"
require "fileutils"
require "pathname"

module Moku
  RSpec.describe Lazy::Origin do
    class TestOrigin < Lazy::Origin
      register(self)
      def self.handles?(*_sources)
        true
      end
    end

    describe "::for" do
      it { expect(described_class.for(Pathname.pwd)).to be_an_instance_of TestOrigin }
      it { expect(described_class.for(1)).to be_an_instance_of TestOrigin }
      it { expect(described_class.for(1, 2)).to be_an_instance_of TestOrigin }
    end

    describe "#read" do
      let(:source1) { double(:source1, read: "one") }
      let(:source2) { double(:source2, read: "two") }
      let(:origin) { described_class.new(source1, source2) }

      it "defers" do
        expect(origin.read).to eql("one")
      end
    end

    describe "#extname" do
      let(:source1) { double(:source1, extname: "one") }
      let(:source2) { double(:source2, extname: "two") }
      let(:origin) { described_class.new(source1, source2) }

      it "defers" do
        expect(origin.extname).to eql("one")
      end
    end

    describe "#merge?" do
      context "with exactly one source" do
        let(:origin) { described_class.new(1) }

        it "is false" do
          expect(origin.merge?).to be false
        end
      end

      context "with more than one source" do
        let(:origin) { described_class.new(1, 2) }

        it "is true" do
          expect(origin.merge?).to be true
        end
      end
    end

    describe "#write" do
      let(:source) { double(:source, read: contents) }
      let(:contents) { "foo\nbar" }
      let(:origin) { TestOrigin.new(source) }
      let(:dest) { Pathname.new("some/dest") }

      before(:each) do
        allow(FileUtils).to receive(:mkdir_p)
        allow(::File).to receive(:write)
        allow(FileUtils).to receive(:cp)
      end

      it "creates the directory with mkdir_p semantics" do
        expect(FileUtils).to receive(:mkdir_p).with(dest.dirname)
        TestOrigin.new(1).write(dest)
      end

      context "when it is a merge" do
        before(:each) { allow(origin).to receive(:merge?).and_return(true) }

        it "writes the contents" do
          expect(::File).to receive(:write).with(dest, contents)
          origin.write(dest)
        end
      end

      context "when it is not a merge" do
        before(:each) { allow(origin).to receive(:merge?).and_return(false) }

        it "copies the path" do
          expect(::FileUtils).to receive(:cp).with(source, dest)
          origin.write(dest)
        end
        it "can write nested contents" do
          expect(::FileUtils).to receive(:cp).with(source, dest)
          TestOrigin.new(origin).write(dest)
        end
      end
    end
  end
end
