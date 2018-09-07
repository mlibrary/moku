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

    let(:artifact) { double(:artifact) }
    let(:deploy_config) do
      double(:deploy_config,
        appname: "myapp-mystage",
        deployer_env: "foo.rails",
        assets_prefix: "assets",
        rails_env: "production",
        deploy_dir: "/path/to/deploy/dir")
    end
    before(:each) do
      allow(deploy_config).to receive(:runner).and_return(runner)
    end

    let(:release) do
      described_class.new(
        deploy_config: deploy_config,
        artifact: artifact,
      )
    end

    describe "#deploy" do
      it "calls deploy with the artifact" do
        expect(runner).to receive(:deploy)
          .with(artifact)
        release.deploy
      end
    end
  end
end
