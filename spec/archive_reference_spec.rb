require_relative "./spec_helper"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/archive_reference"
require "fauxpaas/components/git_runner"
require "pathname"

module Fauxpaas
  RSpec.describe ArchiveReference do
    let(:url) { "https://example.com/fake.git" }
    let(:runner) { Fauxpaas::SpoofedGitRunner.new }
    let(:root_dir) { Pathname.new("some/dir") }
    let(:reference) { described_class.new(url, runner.branch, root_dir) }
    before(:each) { Fauxpaas.git_runner = runner }

    describe "#reference" do
      it "resolves a branch to its latest commit" do
        expect(reference.at(runner.branch)).to eql(
          described_class.new(url, runner.long_for(runner.branch), root_dir)
        )
      end
      it "resolves a short commit unchanged" do
        expect(reference.at(runner.short)).to eql(
          described_class.new(url, runner.long_for(runner.short), root_dir)
        )
      end
      it "resolves a long commit to itself" do
        expect(reference.at(runner.long)).to eql(
          described_class.new(url, runner.long_for(runner.long), root_dir)
        )
      end
      it "resolves a dumb tag to its smart commit" do
        expect(reference.at(runner.dumb_tag)).to eql(
          described_class.new(url, runner.long_for(runner.smart_tag), root_dir)
        )
      end
      it "resolves a smart tag to its commit" do
        expect(reference.at(runner.smart_tag)).to eql(
          described_class.new(url, runner.long_for(runner.smart_tag), root_dir)
        )
      end
    end

    describe "#checkout" do
      let(:cloned_dir) { Pathname.new("/tmp/foo/fauxpaas") }
      let(:relative_files) {[Pathname.new("out.txt"), root_dir, root_dir/"in.txt"]}
      let(:real_files) { relative_files.map{|f| cloned_dir/f } }
      let(:wd) do
        double(:wd,
          dir: cloned_dir,
          relative_files: relative_files,
          real_files: real_files
        )
      end
      before(:each) { allow(runner).to receive(:safe_checkout).and_yield(wd) }
      it "yields a WorkingDirectory with correct relative_paths" do
        reference.checkout do |wd|
          expect(wd.relative_files).to match_array([Pathname.new("in.txt")])
        end
      end
      it "yields a WorkingDirectory with correct real_paths" do
        reference.checkout do |wd|
          expect(wd.real_files).to match_array([
            cloned_dir/root_dir/"in.txt"
          ])
        end
      end
      it "yields a WorkingDirectory with correct dir" do
        reference.checkout do |wd|
          expect(wd.dir).to eql(cloned_dir/root_dir)
        end
      end
    end

    describe "#latest" do
      it "resolves the default_branch to its latest commit" do
        expect(reference.latest).to eql(
          described_class.new(url, runner.long_for(runner.branch), root_dir)
        )
      end
    end

    describe "serialization" do
      it "can serialize and deserialize itself (hashify)" do
        expect(described_class.from_hash(reference.to_hash)).to eql(reference)
      end
    end
  end
end
