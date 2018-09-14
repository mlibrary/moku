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
    let(:artifact) { double(:artifact) }
    let(:deploy_runner) { double(:deploy_runner) }
    let(:deploy_config) { double(:deploy_config, runner: deploy_runner) }
    let(:signature) { double(:signature, deploy: double(:deploy_ref)) }
    let(:artifact_builder) { double(:artifact_builder, build: artifact) }

    before(:each) do
      Fauxpaas.config.register(:artifact_builder) { artifact_builder }
      allow(DeployConfig).to receive(:from_ref).with(signature.deploy, Fauxpaas.ref_repo)
                         .and_return(deploy_config)
      allow(deploy_runner).to receive(:deploy).with(artifact)
    end

    let(:release) do
      described_class.new(signature)
    end

    describe "#deploy" do
      it "calls deploy with the artifact" do
        expect(deploy_runner).to receive(:deploy).with(artifact)
        release.deploy
      end
    end
  end
end
