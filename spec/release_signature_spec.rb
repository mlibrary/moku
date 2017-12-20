require_relative "./spec_helper"
require "fauxpaas/archive_reference"
require "fauxpaas/release_signature"

module Fauxpaas
  RSpec.describe ReleaseSignature do
    let(:signature) do
      described_class.new(
        source: ArchiveReference.new("source_url", "source_ref"),
        infrastructure: ArchiveReference.new("infra_url", "infra_ref"),
        deploy: ArchiveReference.new("deploy_url", "deploy_ref")
      )
    end
  end
end
