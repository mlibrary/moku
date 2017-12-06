require_relative "./spec_helper"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/infrastructure_archive"
require "fauxpaas/infrastructure"
require "pathname"

module Fauxpaas
  RSpec.describe InfrastructureArchive do
    let(:infrastructure) { Infrastructure.new({a: 1, b: "two"}) }
    let(:runner) { SpoofedGitRunner.new }
    let(:url) { "https://example.com/fake.git" }
    let(:tmpdir) { Pathname.new("/tmp") }
    let(:root_dir) { Pathname.new("some/dir") }
    let(:fs) { double(:fs) }

    let(:infrastructure_archive) { described_class.new(url, runner.branch, root_dir, fs: fs) }

    before(:each) do
      Fauxpaas.git_runner = runner
      allow(runner).to receive(:safe_checkout).with(url, runner.branch)
        .and_yield(tmpdir)
      allow(fs).to receive(:read).with(tmpdir/root_dir/"infrastructure.yml")
        .and_return(YAML.dump(infrastructure.to_hash))
    end

    describe "#infrastructure" do
      it "builds an infrastructure object from the reference" do
        expect(infrastructure_archive.infrastructure).to eql(infrastructure)
      end
    end

  end
end
