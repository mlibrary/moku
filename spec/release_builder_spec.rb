# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/release_builder"
require "fauxpaas/deploy_config"
require "fauxpaas/release"
require "fauxpaas/release_signature"
require "pathname"

module Fauxpaas
  class FakeLazyDir
    attr_reader :path
    def initialize(path)
      @path = path
    end

    def cp(base)
      self.class.new(base)
    end

    def write
      self
    end
  end

  RSpec.describe ReleaseBuilder do
    let(:ref_repo) { double(:ref_repo) }
    let(:tmpdir) { Pathname.new "/tmp/dir" }
    let(:source) { double(:source) }
    let(:unshared) { double(:unshared) }
    let(:shared) { double(:shared) }
    let(:deploy) { double(:deploy) }
    let(:deploy_content) do
      {
        "appname"       => "myapp-mystage",
        "deployer_env"  => "foo.capfile",
        "rails_env"     => "testing",
        "assets_prefix" => "asssets",
        "deploy_dir"    => "/some/deploy/dir"
      }
    end
    let(:deploy_config) { DeployConfig.from_hash(deploy_content)  }
    let(:builder) { described_class.new(ref_repo) }

    before(:each) do
      allow(Dir).to receive(:mktmpdir).and_return(tmpdir.to_s)
      allow(DeployConfig).to receive(:from_ref).with(deploy, ref_repo).and_return(deploy_config)
      allow(ref_repo).to receive(:resolve).with(source).and_return(FakeLazyDir.new("/some_source"))
      allow(ref_repo).to receive(:resolve).with(shared).and_return(FakeLazyDir.new("/some_shared"))
      allow(ref_repo).to receive(:resolve).with(unshared).and_return(FakeLazyDir.new("/some_unshared"))
    end

    describe "#release" do
      context "with non-empty shared, unshared" do
        let(:signature) do
          ReleaseSignature.new(
            shared: shared,
            unshared: unshared,
            deploy: deploy,
            source: source
          )
        end

        it "builds the release that corresponds to the signature" do
          release = builder.build(signature)
          expect(release).to eql(
            Release.new(
              source_path: tmpdir/"source",
              shared_path: tmpdir/"shared",
              unshared_path: tmpdir/"unshared",
              deploy_config: DeployConfig.from_hash(deploy_content)
            )
          )
        end
      end
    end
  end
end
