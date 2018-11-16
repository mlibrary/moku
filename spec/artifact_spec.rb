# frozen_string_literal: true

require "moku/artifact"
require "pathname"

module Moku
  RSpec.describe Artifact do
    let(:path) { Pathname.new("/some/path") }
    let(:signature) do
      double(
        :signature,
        deploy: double(:deploy),
        source: double(:source),
        shared: double(:shared),
        unshared: double(:unshared)
      )
    end
    let(:artifact) do
      described_class.new(
        path: path,
        signature: signature
      )
    end

    it { expect(artifact.path).to eql(path) }
    it { expect(artifact.source).to eql(signature.source) }
    it { expect(artifact.shared).to eql(signature.shared) }
    it { expect(artifact.unshared).to eql(signature.unshared) }
  end
end
