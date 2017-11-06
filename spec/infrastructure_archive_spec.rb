require_relative "./spec_helper"
require "fauxpaas/infrastructure_archive"
require "fauxpaas/infrastructure"
require "pathname"

module Fauxpaas
  RSpec.describe InfrastructureArchive do
    let(:archive) { double(:archive) }
    let(:reference) { double(:reference) }
    let(:path) { Pathname.new("some/path") }
    let(:tmpdir) { Pathname.new("/tmp/dir") }
    let(:fs) { double(:fs) }
    let(:contents) {{ a: 1, b: "two" } }
    let(:infra_archive) { described_class.new(archive, root_dir: path, fs: fs) }

    before(:each) do
      allow(archive).to receive(:checkout).with(reference).and_yield(tmpdir)
      allow(fs).to receive(:read).with(tmpdir + path + "infrastructure.yml")
        .and_return(YAML.dump(contents))
    end

    describe "#infrastructure" do
      it "builds an infrastructure object from the reference" do
        expect(infra_archive.infrastructure(reference))
          .to eql(Infrastructure.new(contents))
      end
    end
  end
end
