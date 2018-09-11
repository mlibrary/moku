# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/archive_reference"
require "pathname"

module Fauxpaas
  RSpec.describe ArchiveReference do
    let(:url) { "https://example.com/fake.git" }
    let(:runner) { Fauxpaas.git_runner }
    let(:reference) { described_class.new(url, runner.branch, runner) }

    describe "#at" do
      it "resolves a branch to its latest commit" do
        expect(reference.at(runner.branch)).to eql(
          described_class.new(url, runner.long_for(runner.branch), runner)
        )
      end
      it "resolves a short commit unchanged" do
        expect(reference.at(runner.short)).to eql(
          described_class.new(url, runner.long_for(runner.short), runner)
        )
      end
      it "resolves a long commit to itself" do
        expect(reference.at(runner.long)).to eql(
          described_class.new(url, runner.long_for(runner.long), runner)
        )
      end
      it "resolves a dumb tag to its smart commit" do
        expect(reference.at(runner.dumb_tag)).to eql(
          described_class.new(url, runner.long_for(runner.smart_tag), runner)
        )
      end
      it "resolves a smart tag to its commit" do
        expect(reference.at(runner.smart_tag)).to eql(
          described_class.new(url, runner.long_for(runner.smart_tag), runner)
        )
      end
    end

    describe "#branch" do
      it "resolves a branch unchanged" do
        expect(reference.branch(runner.branch)).to eql(
          described_class.new(url, runner.branch, runner)
        )
      end
    end

    describe "#latest" do
      it "resolves the default_branch to its latest commit" do
        expect(reference.latest).to eql(
          described_class.new(url, runner.long_for(runner.branch), runner)
        )
      end
    end

    describe "serialization" do
      it "can serialize and deserialize itself (hashify)" do
        expect(described_class.from_hash(reference.to_hash, runner))
          .to eql(reference)
      end
    end
  end
end
