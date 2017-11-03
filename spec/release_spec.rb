# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require "fauxpaas/release"
require "fauxpaas/infrastructure"
require "fauxpaas/deploy_config"
require "fauxpaas/git_reference"
require "yaml"

module Fauxpaas
  RSpec.describe Release do
    let(:success) { double(:success, success?: true) }
    let(:runner) { double(:runner, run: [nil, nil, success]) }
    let(:fs) { MemoryFilesystem.new }
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
        source: source,
        fs: fs
      )
    end

    describe "#deploy" do
      it "writes the infrastructure in a temporary dir" do
        expect(fs).to receive(:write).with(
          fs.tmpdir + "infrastructure.yml",
          YAML.dump(infrastructure.to_hash)
        )
        release.deploy
      end

      it "uses the appname as the stage" do
        expect(runner).to receive(:run).with("myapp-mystage", anything, anything)
        release.deploy
      end

      it "runs the 'deploy' task" do
        expect(runner).to receive(:run).with(anything, "deploy", anything)
        release.deploy
      end

      it "sets :infrastructure_config_path" do
        expect(runner).to receive(:run).with(anything, anything, a_hash_including(
          infrastructure_config_path: (fs.tmpdir + "infrastructure.yml").to_s
        ))
        release.deploy
      end

      it "sets :branch" do
        expect(runner).to receive(:run).with(anything, anything, a_hash_including(
          branch: source.reference
        ))
        release.deploy
      end

      it "sets :source_repo" do
        expect(runner).to receive(:run).with(anything, anything, a_hash_including(
          source_repo: source.url
        ))
        release.deploy
      end

      it "sets the deploy options" do
        expect(runner).to receive(:run).with(anything, anything, a_hash_including(
          deploy_config.to_hash
        ))
        release.deploy
      end

    end
  end
end
