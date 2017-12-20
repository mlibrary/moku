# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/release_builder"
require "fauxpaas/deploy_config"
require "fauxpaas/release"
require "fauxpaas/release_signature"
require "fauxpaas/components/git_runner"
require "pathname"
require "yaml"

module Fauxpaas
  class FakeWorkingDir
    def initialize(dir, files)
      @dir = dir
      @files = files
    end
    attr_reader :dir
    def relative_files; @files; end
  end

  RSpec.describe ReleaseBuilder do
    let(:source) { double(:source) }
    let(:unshared) { double(:unshared) }
    let(:shared) { double(:shared) }
    let(:deploy) { double(:deploy) }
    let(:runner) { SpoofedGitRunner.new  }
    let(:deploy_content) do
      {
        "appname" => "myapp-mystage",
        "deployer_env" => "foo.capfile",
        "rails_env" => "testing",
        "assets_prefix" => "asssets",
        "deploy_dir" => "/some/deploy/dir"
      }
    end
    let(:fs) do
      MemoryFilesystem.new({
        runner.tmpdir/"deploy.yml"         => YAML.dump(deploy_content),
        runner.tmpdir/"infrastructure.yml" => YAML.dump({a: 1, b: 2}),
        runner.tmpdir/"my_shared.yml" => YAML.dump("blahblah"),
      })
    end

    let(:builder) { described_class.new(signature, fs: fs) }

    before(:each) do
      Fauxpaas.git_runner = runner
      allow(unshared).to receive(:checkout)
        .and_yield(FakeWorkingDir.new(fs.tmpdir, [Pathname.new("infrastructure.yml")]))
      allow(shared).to receive(:checkout)
        .and_yield(FakeWorkingDir.new(fs.tmpdir, [Pathname.new("myshared.yml")]))
      allow(deploy).to receive(:checkout)
        .and_yield(FakeWorkingDir.new(fs.tmpdir, [runner.tmpdir/"deploy.yml"]))
    end

    describe "#release" do
      context "with empty shared, unshared" do
        let(:signature) do
          ReleaseSignature.new(
            shared: [],
            unshared: [],
            deploy: deploy,
            source: source
          )
        end
        it "creates the shared dir" do
          allow(fs).to receive(:mkdir_p).and_call_original
          expect(fs).to receive(:mkdir_p).with(fs.tmpdir/"shared")
          builder.build
        end
        it "creates the unshared dir" do
          allow(fs).to receive(:mkdir_p).and_call_original
          expect(fs).to receive(:mkdir_p).with(fs.tmpdir/"unshared")
          builder.build
        end
      end

      context "with non-empty shared, unshared" do
        let(:signature) do
          ReleaseSignature.new(
            shared: [shared],
            unshared: [unshared],
            deploy: deploy,
            source: source
          )
        end

        it "builds the release that corresponds to the signature" do
          release = builder.build
          expect(release).to eql(
            Release.new(
              source: signature.source,
              shared_path: fs.tmpdir/"shared",
              unshared_path: fs.tmpdir/"unshared",
              deploy_config: DeployConfig.from_hash(deploy_content)
            )
          )
        end
      end
    end

  end
end
