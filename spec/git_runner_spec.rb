require_relative "./spec_helper"
require "fauxpaas/components"
require "fauxpaas/git_runner"

module Fauxpaas
  RSpec.describe GitRunner do
    let(:kernel) { double(:kernel, run: raw_output) }
    let(:runner) { described_class.new(kernel) }

    let(:url) { "url" }
    let(:commitish) { "commitish" }
    describe "#ls_remote" do
      let(:raw_output) do
        "5753224412a302aeedfdd73e7b04d914c298c169  HEAD\n" \
        "5753224412a302aeedfdd73e7b04d914c298c169  refs/heads/develop\n" \
        "66b689fbb3e5b689c3560d24dd50ac9027d94dbe  refs/heads/feature/aeid-94-restart\n" \
        "34cfe233054f3353b4576d3a29ede56c09d32658  refs/heads/fixup/config\n" \
        "022702e093cc0071f88e66ca54ae8886397cc11a  refs/heads/fixup/deploy_releases\n" \
        "1128b45d32156fb49d9f15359ebe38e3dd5e3ac1  refs/heads/master\n" \
        "ad6b82c09e26b7f09d1512596cc32d0dad3d9bc2  refs/pull/1/head\n" \
        "5777acb0c7f3bf5a4c30731904c11dcd7045f3cf  refs/pull/10/head\n" \
        "f44af182ef3cae3d9c6946c18284658ac78008ac  refs/pull/11/head\n" \
      end
      let(:output) do
        [
          ["5753224412a302aeedfdd73e7b04d914c298c169",  "HEAD"],
          ["5753224412a302aeedfdd73e7b04d914c298c169",  "refs/heads/develop"],
          ["66b689fbb3e5b689c3560d24dd50ac9027d94dbe",  "refs/heads/feature/aeid-94-restart"],
          ["34cfe233054f3353b4576d3a29ede56c09d32658",  "refs/heads/fixup/config"],
          ["022702e093cc0071f88e66ca54ae8886397cc11a",  "refs/heads/fixup/deploy_releases"],
          ["1128b45d32156fb49d9f15359ebe38e3dd5e3ac1",  "refs/heads/master"],
          ["ad6b82c09e26b7f09d1512596cc32d0dad3d9bc2",  "refs/pull/1/head"],
          ["5777acb0c7f3bf5a4c30731904c11dcd7045f3cf",  "refs/pull/10/head"],
          ["f44af182ef3cae3d9c6946c18284658ac78008ac",  "refs/pull/11/head"]
        ]
      end
      it "executes git ls-remote url ref" do
        expect(kernel).to receive(:run).with("git ls-remote #{url} #{commitish}")
        runner.ls_remote(url, commitish)
      end

      it "returns a list of [sha, refname]" do
        expect(runner.ls_remote(url, commitish)).to eql(output)
      end
    end

    describe "#rev_parse" do
      let(:raw_output) { "5753224412a302aeedfdd73e7b04d914c298c169\n" }
      let(:output) { raw_output.strip }
      it "executes git rev-parse <args>" do
        expect(kernel).to receive(:run).with("git rev-parse #{commitish}")
        runner.rev_parse(commitish)
      end

      it "returns a sha" do
        expect(runner.rev_parse(commitish)).to eql(output)
      end
    end

    describe "#safe_checkout" do
      let(:runner) { described_class.new }
      let(:url) { Fauxpaas.root + ".git" }
      let(:commit) { "00dd3a5a8dbb1c19809cfb1499829defd8e16e49" }
      it "yields a tmp dir" do
        tmpdir = runner.safe_checkout(url, commit) do |dir|
          expect(dir.exist?).to be true
          dir
        end
        expect(tmpdir.exist?).to be false
      end

      it "checks out the ref" do
        checked_out = runner.safe_checkout(url, commit) do |dir|
          Dir.chdir(dir) do
            `git rev-parse HEAD`.strip
          end
        end
        expect(checked_out).to eql(commit)
      end

    end
  end
end
