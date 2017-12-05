# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/release_builder"
require "fauxpaas/archive_reference"
require "fauxpaas/deploy_config"
require "fauxpaas/release"
require "fauxpaas/release_signature"
require "fauxpaas/components/git_runner"
require "pathname"
require "yaml"

module Fauxpaas
  RSpec.describe ReleaseBuilder do
    let(:infra_content) {{a: 1, b: 2}}
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
        runner.tmpdir/"infrastructure.yml" => YAML.dump(infra_content)
      })
    end
    let(:shared_archives) { [ArchiveReference.new("infra.git", runner.branch)] }
    let(:unshared_archives) { [] }
    let(:deploy_archive) { ArchiveReference.new("deploy.git", runner.branch) }
    let(:source_archive) { ArchiveReference.new("source.git", runner.branch) }

    let(:signature) do
      ReleaseSignature.new(
        shared: shared_archives,
        unshared: unshared_archives,
        deploy: deploy_archive,
        source: source_archive
      )
    end

    let(:builder) { described_class.new(signature, fs: fs) }
    let(:runner) { SpoofedGitRunner.new  }
    before(:each) { Fauxpaas.git_runner = runner }

    describe "#release" do
      context "with empty shared, unshared" do
        let(:shared_archives) { [] }
        let(:unshared_archives) { [] }
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
      it "builds the release that corresponds to the signature" do
        expect(builder.build).to eql(
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
