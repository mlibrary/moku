require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require "fauxpaas/components"
require "fauxpaas/git_runner"

module Fauxpaas
  RSpec.describe GitRunner do
    describe "#safe_checkout" do
      let(:url) { Fauxpaas.root + ".git" }
      let(:commit) { "00dd3a5a8dbb1c19809cfb1499829defd8e16e49" }

      context "fully mocked" do
        let(:system_runner) { double(:system_runner, run: "") }
        let(:fs) { MemoryFilesystem.new }
        let(:runner) { described_class.new(system_runner: system_runner, fs: fs) }
        it "yields a tmp dir" do
          runner.safe_checkout(url, commit) do |dir|
            expect(dir).to eql(fs.tmpdir + "fauxpaas")
          end
        end
      end

      context "integration" do
        let(:runner) { described_class.new }
        it "checks out the ref", broken_in_travis: true do
          runner.safe_checkout(url, commit) do |dir|
            expect(`git -C #{dir} rev-parse HEAD`.strip)
              .to eql(commit)
          end
        end
      end

    end
  end
end

