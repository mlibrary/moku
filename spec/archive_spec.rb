require_relative "./spec_helper"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/components"
require "fauxpaas/archive"

module Fauxpaas
  RSpec.describe Archive do
    let(:url) { "https://example.com/fake.git" }
    let(:runner) { SpoofedGitRunner.new }
    let(:archive) { described_class.new(url, default_branch: runner.branch) }

    before(:each) { Fauxpaas.git_runner = runner }

    describe "#reference" do
      it "resolves a branch to its latest commit" do
        expect(archive.reference(runner.branch)).to eql(
          Fauxpaas::GitReference.new(url, runner.long_for(runner.branch))
        )
      end
      it "resolves a short commit unchanged" do
        expect(archive.reference(runner.short)).to eql(
          Fauxpaas::GitReference.new(url, runner.long_for(runner.short))
        )
      end
      it "resolves a long commit to itself" do
        expect(archive.reference(runner.long)).to eql(
          Fauxpaas::GitReference.new(url, runner.long_for(runner.long))
        )
      end
      it "resolves a dumb tag to its smart commit" do
        expect(archive.reference(runner.dumb_tag)).to eql(
          Fauxpaas::GitReference.new(url, runner.long_for(runner.smart_tag))
        )
      end
      it "resolves a smart tag to its commit" do
        expect(archive.reference(runner.smart_tag)).to eql(
          Fauxpaas::GitReference.new(url, runner.long_for(runner.smart_tag))
        )
      end
    end

    describe "#default_branch" do
      it "defaults to master" do
        expect(described_class.new(url).default_branch).to eql("master")
      end

      it "can be set" do
        expect(described_class.new(url, default_branch: "foo").default_branch)
          .to eql("foo")
      end
    end

    describe "#latest" do
      it "resolves the default_branch to its latest commit" do
        expect(archive.latest).to eql(
          Fauxpaas::GitReference.new(url, runner.long_for(runner.branch))
        )
      end
    end

    describe "serialization" do
      it "can serialize and deserialize itself (hashify)" do
        expect(Archive.from_hash(archive.to_hash)).to eql(archive)
      end
    end

  end
end
