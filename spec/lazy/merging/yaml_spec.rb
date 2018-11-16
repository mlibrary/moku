# frozen_string_literal: true

require "moku/lazy/merging/yaml"

module Moku
  RSpec.describe Lazy::Merging::Yaml do
    let(:foo_yml) { Pathname.new("foo.yml") }
    let(:bar_yaml) { Pathname.new("bar.yaml") }

    describe "::handles?" do
      it "handles yaml files" do
        expect(described_class.handles?(foo_yml, bar_yaml))
          .to be true
      end
      it "doesn't handle a single yaml file" do
        expect(described_class.handles?(foo_yml)).to be false
      end
    end

    describe "#extname" do
      let(:origin) { described_class.new(foo_yml, bar_yaml) }

      it "is .yml" do
        expect(origin.extname).to eql(".yml")
      end
    end

    describe "#read" do
      xit "merges the two yaml files"
    end
  end
end
