require_relative "./spec_helper"
require "fauxpaas/git_reference"
require "fauxpaas/release_signature"

module Fauxpaas
  RSpec.describe ReleaseSignature do
    let(:signature) do
      described_class.new(
        source: GitReference.new("source_url", "source_ref"),
        infrastructure: GitReference.new("infra_url", "infra_ref"),
        deploy: GitReference.new("deploy_url", "deploy_ref")
      )
    end
  end
end
