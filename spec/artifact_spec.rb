# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/artifact"
require "pathname"

module Fauxpaas
  RSpec.describe Artifact do
    let(:path) { Pathname.new("/some/path") }
    let(:artifact) { described_class.new(path) }

    describe "#path" do
      it "has a path" do
        expect(artifact.path).to eql(path)
      end
    end
  end
end
