# frozen_string_literal: true

require_relative "../../support/memory_filesystem"
require "fauxpaas/scm/git/local_resolver"

module Fauxpaas
  RSpec.describe SCM::Git::LocalResolver do
    let(:status) { double(:status, success?: true, output: raw) }
    let(:system_runner) { double(:system_runner, run: status) }
    let(:fs) { MemoryFilesystem.new }
    let(:runner) { described_class.new(system_runner) }
    let(:url) { "url" }
    let(:commitish) { "commitish" }

    describe "#sha" do
      let(:raw) { "5753224412a302aeedfdd73e7b04d914c298c169\n" }
      let(:expected) { raw.strip }

      it "executes git rev-parse <args>" do
        expect(system_runner).to receive(:run)
          .with("git -C #{url} rev-parse #{commitish}")
        runner.sha(url, commitish)
      end

      it "returns a sha" do
        expect(runner.sha(url, commitish)).to eql(expected)
      end
    end
  end
end
