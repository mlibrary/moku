require_relative "./spec_helper"
require "fauxpaas/infrastructure"

module Fauxpaas
  RSpec.describe Infrastructure do
    let(:options) {{ "a" => 1, "b" => 2 }}
    let(:infrastructure) { described_class.new(options) }
    describe "#to_hash" do
      it "returns a hash with string keys" do
        expect(infrastructure.to_hash).to eql(options)
      end
    end

    describe "#eql?" do
      it "doesn't care if the keys are strings or symbols" do
        expect(described_class.new("a" => 1).eql?(described_class.new(a: 1))).to be true
      end
    end

    describe "serialization" do
      it "can serialize and deserialize itself (hashify)" do
        expect(described_class.from_hash(infrastructure.to_hash)).to eql(infrastructure)
      end
    end
  end
end
