# frozen_string_literal: true

require "fauxpaas/lazy/merging/overwrite"

module Fauxpaas
  RSpec.describe Lazy::Merging::Overwrite do
    describe "::handles?" do
      it "handles everything (default)" do
        expect(described_class.handles?(5)).to be true
      end
    end

    describe "#extname" do
      let(:source1) { double(:source1, extname: "one") }
      let(:source2) { double(:source2, extname: "two") }
      let(:origin) { described_class.new(source1, source2) }

      it "returns the extension of the last source" do
        expect(origin.extname).to eql("two")
      end
    end

    describe "#read" do
      let(:source1) { double(:source1, read: "one") }
      let(:source2) { double(:source2, read: "two") }
      let(:origin) { described_class.new(source1, source2) }

      it "is the content of the last source" do
        expect(origin.read).to eql("two")
      end
    end
  end
end
