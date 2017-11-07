require_relative "./spec_helper"
require "fauxpaas/components"
require "fauxpaas/git_runner"

module Fauxpaas
  RSpec.describe GitRunner do
    let(:system_runner) { double(:system_runner, run: raw) }
    let(:runner) { described_class.new(system_runner) }
    let(:url) { "url" }
    let(:commitish) { "commitish" }

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
