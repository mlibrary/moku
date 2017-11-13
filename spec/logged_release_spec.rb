require_relative "./spec_helper"
require "fauxpaas/logged_release"
require "fauxpaas/release_signature"
require "fauxpaas/git_reference"

module Fauxpaas
  RSpec.describe LoggedRelease do
    let(:sig) do
      ReleaseSignature.new(
        source: GitReference.new("source_url", "source_ref"),
        infrastructure: GitReference.new("infra_url", "infra_ref"),
        deploy: GitReference.new("deploy_url", "deploy_ref")
      )
    end
    let(:user) { "foouser" }
    let(:time) { Time.new(2017, 1, 31, 13, 44, 11) }
    let(:formatted_time) { time.strftime("%FT%T") }
    let(:logged_release) { described_class.new(user, time, sig) }

    describe "#to_s" do
      it "returns a formatted string" do
        expect(logged_release.to_s).to eql(
          "2017-01-31T13:44:11: foouser source_ref infra_ref w/ deploy_ref"
        )
      end
    end

    describe "#to_hash" do
      let(:hash) do
        {
          user: user,
          time: formatted_time,
          signature: sig.to_hash
        }
      end
      it "exports its elements" do
        expect(logged_release.to_hash).to eql(hash)
      end
    end

    describe "::from_hash" do
      it "instantiates from a hash" do
        expect(described_class.from_hash(logged_release.to_hash).to_hash)
          .to eql(logged_release.to_hash)
      end
    end

  end

end
