require_relative "./spec_helper"
require "fauxpaas/deploy_archive"
require "fauxpaas/deploy_config"
require "pathname"

module Fauxpaas
  RSpec.describe DeployArchive do
    let(:archive) { double(:archive) }
    let(:reference) { double(:reference) }
    let(:path) { Pathname.new("some/path") }
    let(:tmpdir) { Pathname.new("/tmp/dir") }
    let(:fs) { double(:fs) }
    let(:deploy_config) do
      DeployConfig.new(
        appname: "myapp-mystage",
        deployer_env: "foo.capfile",
        assets_prefix: "assets",
        rails_env: "production",
        deploy_dir: "/path/to/deploy/dir"
      )
    end

    let(:deploy_archive) { described_class.new(archive, root_dir: path, fs: fs) }

    before(:each) do
      allow(archive).to receive(:checkout).with(reference).and_yield(tmpdir)
      allow(fs).to receive(:read).with(tmpdir + path + "deploy.yml")
        .and_return(YAML.dump(deploy_config.to_hash))
    end

    describe "#deploy_config" do
      it "builds a deploy_config object from the reference" do
        expect(deploy_archive.deploy_config(reference))
          .to eql(deploy_config)
      end
    end
  end
end
