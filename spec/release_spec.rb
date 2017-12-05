# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/release"
require "fauxpaas/deploy_config"
require "fauxpaas/archive_reference"
require "yaml"

module Fauxpaas
  RSpec.describe Release do
    let(:success) { double(:success, success?: true) }
    let(:runner) { double(:runner, run: [nil, nil, success]) }
    let(:source) { ArchiveReference.new("source.git", "1238019283019823019823091832") }
    let(:shared_path) { Pathname.new("/tmp/shared/structure") }
    let(:unshared_path) { Pathname.new("/tmp/unshared/structure") }
    let(:deploy_config) do
      DeployConfig.new(
        appname: "myapp-mystage",
        deployer_env: "foo.rails",
        assets_prefix: "assets",
        rails_env: "production",
        deploy_dir: "/path/to/deploy/dir"
      )
    end
    before(:each) do
      allow(deploy_config).to receive(:runner).and_return(runner)
    end

    let(:release) do
      described_class.new(
        deploy_config: deploy_config,
        shared_path: shared_path,
        unshared_path: unshared_path,
        source: source
      )
    end

    describe "#deploy" do
      it "calls deploy with the shared_path" do
        expect(runner).to receive(:deploy)
          .with(anything, shared_path, anything)
        release.deploy
      end
      it "calls deploy with the unshared_path" do
        expect(runner).to receive(:deploy)
          .with(anything, anything, unshared_path)
        release.deploy
      end
      it "calls deploy with the source" do
        expect(runner).to receive(:deploy)
          .with(source, anything, anything)
        release.deploy
      end
    end
  end
end
