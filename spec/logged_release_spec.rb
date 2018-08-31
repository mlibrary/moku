# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/logged_release"
require "fauxpaas/release_signature"

module Fauxpaas
  RSpec.describe LoggedRelease do
    let(:source_url) { "source_url" }
    let(:source_ref) { "source_ref" }
    let(:source) do
      double(:source,
        url: source_url,
        commitish: source_ref,
        to_hash: { url: source_url, commitish: source_ref })
    end

    let(:shared_url) { "shared_url" }
    let(:shared_ref) { "shared_ref" }
    let(:shared) do
      double(:shared,
        url: shared_url,
        commitish: shared_ref,
        to_hash: { url: shared_url, commitish: shared_ref })
    end

    let(:unshared_url) { "unshared_url" }
    let(:unshared_ref) { "unshared_ref" }
    let(:unshared) do
      double(:unshared,
        url: unshared_url,
        commitish: unshared_ref,
        to_hash: { url: unshared_url, commitish: unshared_ref })
    end

    let(:deploy_url) { "deploy_url" }
    let(:deploy_ref) { "deploy_ref" }
    let(:deploy) do
      double(:deploy,
        url: deploy_url,
        commitish: deploy_ref,
        to_hash: { url: deploy_url, commitish: deploy_ref })
    end

    let(:user) { "foouser" }
    let(:time) { Time.new(2017, 1, 31, 13, 44, 11) }
    let(:formatted_time) { time.strftime("%FT%T") }
    let(:logged_release) { described_class.new(user, time, sig) }

    let(:sig) do
      ReleaseSignature.new(
        source: source,
        shared: shared,
        unshared: unshared,
        deploy: deploy
      )
    end

    describe "#to_s" do
      context "with single shared,unshared" do
        it "returns a formatted string" do
          expect(logged_release.to_s).to eql(
            "2017-01-31T13:44:11: foouser source_ref w/ deploy_ref\n" \
            "  unshared_ref\n" \
            "  shared_ref"
          )
        end
      end
    end

    describe "#to_brief_hash" do
      it "returns a hash of shas" do
        expect(logged_release.to_brief_hash).to eql(
          user: user,
          time: formatted_time,
          source: source_ref,
          deploy: deploy_ref,
          unshared: unshared_ref,
          shared: shared_ref
        )
      end
    end

    describe "#to_hash" do
      let(:hash) do
        {
          user:      user,
          time:      formatted_time,
          signature: sig.to_hash
        }
      end
      it "exports its elements" do
        expect(logged_release.to_hash).to eql(hash)
      end
    end

    describe "::from_hash" do
      before(:each) do
        allow(ReleaseSignature).to receive(:from_hash).with(sig.to_hash)
          .and_return(sig)
      end
      it "instantiates from a hash" do
        expect(described_class.from_hash(logged_release.to_hash).to_hash)
          .to eql(logged_release.to_hash)
      end
    end
  end

end
