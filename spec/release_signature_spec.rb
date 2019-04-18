# frozen_string_literal: true

require "moku/archive_reference"
require "moku/release_signature"

module Moku
  RSpec.describe ReleaseSignature do
    let(:signature) do
      described_class.new(
        source: ArchiveReference.new("source_url", "source_ref"),
        infrastructure: ArchiveReference.new("infra_url", "infra_ref"),
        deploy: ArchiveReference.new("deploy_url", "deploy_ref")
      )
    end

    xit "should have tests"
  end
end
