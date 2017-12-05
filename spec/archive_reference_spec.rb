require_relative "./spec_helper"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/components/git_runner"
require "fauxpaas/archive_reference"
require "pathname"

module Fauxpaas
  RSpec.describe ArchiveReference do
    let(:url) { "https://example.com/fake.git" }
    let(:runner) { SpoofedGitRunner.new }
    let(:root_dir) { Pathname.new("some/dir") }
    let(:reference) { described_class.new(url, runner.branch, root_dir) }
    before(:each) { Fauxpaas.git_runner = runner }

    describe "#reference" do
      it "resolves a branch to its latest commit" do
        expect(reference.at(runner.branch)).to eql(
          Fauxpaas::ArchiveReference.new(url, runner.long_for(runner.branch), root_dir)
        )
      end
      it "resolves a short commit unchanged" do
        expect(reference.at(runner.short)).to eql(
          Fauxpaas::ArchiveReference.new(url, runner.long_for(runner.short), root_dir)
        )
      end
      it "resolves a long commit to itself" do
        expect(reference.at(runner.long)).to eql(
          Fauxpaas::ArchiveReference.new(url, runner.long_for(runner.long), root_dir)
        )
      end
      it "resolves a dumb tag to its smart commit" do
        expect(reference.at(runner.dumb_tag)).to eql(
          Fauxpaas::ArchiveReference.new(url, runner.long_for(runner.smart_tag), root_dir)
        )
      end
      it "resolves a smart tag to its commit" do
        expect(reference.at(runner.smart_tag)).to eql(
          Fauxpaas::ArchiveReference.new(url, runner.long_for(runner.smart_tag), root_dir)
        )
      end
    end

    describe "#latest" do
      it "resolves the default_branch to its latest commit" do
        expect(reference.latest).to eql(
          Fauxpaas::ArchiveReference.new(url, runner.long_for(runner.branch), root_dir)
        )
      end
    end

    describe "serialization" do
      it "can serialize and deserialize itself (hashify)" do
        expect(ArchiveReference.from_hash(reference.to_hash)).to eql(reference)
      end
    end

  end
end
