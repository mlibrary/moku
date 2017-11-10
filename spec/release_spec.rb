# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/release"
require "fauxpaas/infrastructure"
require "fauxpaas/deploy_config"
require "fauxpaas/git_reference"
require "yaml"

module Fauxpaas
  RSpec.describe Release do
    let(:success) { double(:success, success?: true) }
    let(:runner) { double(:runner, run: [nil, nil, success]) }
    let(:infrastructure) { Infrastructure.new({a: 1, b: "two"}) }
    let(:source) { GitReference.new("source.git", "1238019283019823019823091832") }
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
        infrastructure: infrastructure,
        source: source
      )
    end

    describe "#deploy" do
      it "calls deploy with the infrastructure" do
        expect(runner).to receive(:deploy)
          .with(infrastructure, anything)
        release.deploy
      end
      it "calls deploy with the source" do
        expect(runner).to receive(:deploy)
          .with(anything, source)
        release.deploy
      end
    end
  end
end
