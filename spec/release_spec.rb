# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/release"
require "fauxpaas/deploy_config"
require "fauxpaas/archive_reference"
require "yaml"

module Fauxpaas
  class FakeWorkingDir
    def initialize(dir, files)
      @dir = dir
      @files = files
    end
    attr_reader :dir
    def relative_files
      @files
    end
  end

  RSpec.describe Release do
    let(:git_runner) { Fauxpaas.git_runner }

    let(:fs) do
      MemoryFilesystem.new(
        git_runner.tmpdir/"deploy.yml" => YAML.dump({})
      )
    end

    let(:success) { double(:success, success?: true) }
    let(:deploy_runner) { double(:deploy_runner, run: [nil, nil, success]) }
    let(:deploy_config) { double(:deploy_config, runner: deploy_runner) }
    let(:deploy_config_factory) do
      double(:deploy_config_factory,
        from_hash: deploy_config)
    end

    let(:deploy) { double(:deploy) }
    before(:each) do
      allow(deploy).to receive(:checkout)
        .and_yield(FakeWorkingDir.new(fs.tmpdir, [git_runner.tmpdir/"deploy.yml"]))
    end

    let(:signature) { double(:signature, deploy: deploy) }

    let(:artifact) do
      double(:artifact)
    end

    let(:artifact_factory) { double(:artifact_factory) }
    before(:each) do
      allow(artifact_factory).to receive(:new)
        .with(signature: signature, fs: fs)
        .and_return(artifact)
    end

    let(:release) do
      described_class.new(
        signature: signature,
        fs: fs,
        artifact_factory: artifact_factory,
        deploy_config_factory: deploy_config_factory
      )
    end

    describe "#deploy" do
      it "calls deploy with the artifact" do
        expect(deploy_runner).to receive(:deploy).with(artifact)
        release.deploy
      end
    end
  end
end
