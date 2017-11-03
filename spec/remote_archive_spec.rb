require_relative "./spec_helper"
require "fauxpaas/components"
require "fauxpaas/remote_archive"
require_relative "./support/spoofed_git_runner"

module Fauxpaas
  RSpec.describe RemoteArchive do
    let(:url) { "https://example.com/fake.git" }
    let(:runner) { SpoofedGitRunner.new }
    let(:archive) { described_class.new(url, runner, default_branch: runner.branch) }

    describe "#reference" do
      it "resolves a branch to its latest commit" do
        expect(archive.reference(runner.branch)).to eql(
          Fauxpaas::GitReference.new(url, runner.resolved_remote(runner.branch))
        )
      end
      it "resolves a short commit unchanged" do
        expect(archive.reference(runner.short)).to eql(
          Fauxpaas::GitReference.new(url, runner.resolved_remote(runner.short))
        )
      end
      it "resolves a long commit to itself" do
        expect(archive.reference(runner.long)).to eql(
          Fauxpaas::GitReference.new(url, runner.resolved_remote(runner.long))
        )
      end
      it "resolves a tag to its commit" do
        expect(archive.reference(runner.dumb_tag)).to eql(
          Fauxpaas::GitReference.new(url, runner.resolved_remote(runner.smart_tag))
        )
      end
    end

    describe "#default_branch" do
      it "defaults to master" do
        expect(described_class.new(url, runner).default_branch).to eql("master")
      end

      it "can be set" do
        expect(described_class.new(url, runner, default_branch: "foo").default_branch)
          .to eql("foo")
      end
    end

    describe "#latest" do
      it "resolves the default_branch to its latest commit" do
        expect(archive.latest).to eql(
          Fauxpaas::GitReference.new(url, runner.resolved_remote(runner.branch))
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
