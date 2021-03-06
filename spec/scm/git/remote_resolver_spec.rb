# frozen_string_literal: true

require "moku/scm/git/remote_resolver"

module Moku
  RSpec.describe SCM::Git::RemoteResolver do
    let(:status) { double(:status, success?: true, output: raw) }
    let(:system_runner) { double(:system_runner, run: status) }
    let(:runner) { described_class.new(system_runner) }
    let(:url) { "url" }
    let(:commitish) { "commitish" }

    describe "#sha" do
      let(:raw) do
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

      it "executes git ls-remote url ref" do
        expect(system_runner).to receive(:run).with("git ls-remote #{url} #{commitish}")
        runner.sha(url, commitish)
      end

      it "returns the latest sha for the ref" do
        expect(runner.sha(url, commitish))
          .to eql("5753224412a302aeedfdd73e7b04d914c298c169")
      end

      context "when the reference cannot be resolved" do
        let(:raw) { "\n" }

        it "returns nil if the reference cannot be resolved" do
          expect(runner.sha(url, "12345")).to be_nil
        end
      end
    end
  end
end
