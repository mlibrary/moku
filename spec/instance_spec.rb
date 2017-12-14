# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/instance"
require "fauxpaas/archive"
require "fauxpaas/deploy_archive"
require "fauxpaas/infrastructure_archive"
require "fauxpaas/release"
require "fauxpaas/release_signature"
require "fauxpaas/components/git_runner"
require "pathname"

module Fauxpaas
  RSpec.describe Instance do
    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:name) { "#{app}-#{stage}" }

    let(:runner) { SpoofedGitRunner.new  }
    let(:infra_content) {{a: 1, b: 2}}
    let(:infra_archive) do
      InfrastructureArchive.new(
        Archive.new("infra.git", default_branch: runner.branch),
        fs: MemoryFilesystem.new({
          Pathname.new(runner.tmpdir) + "infrastructure.yml" => YAML.dump(infra_content)
        })
      )
    end
    let(:deploy_content) do
      {
        "appname" => name,
        "deployer_env" => "foo.capfile",
        "rails_env" => "testing",
        "assets_prefix" => "asssets",
        "deploy_dir" => "/some/deploy/dir"
      }
    end
    let(:deploy_archive) do
      DeployArchive.new(
        Archive.new("deploy.git", default_branch: runner.branch),
        fs: MemoryFilesystem.new({
          Pathname.new(runner.tmpdir) + "deploy.yml" => YAML.dump(deploy_content)
        })
      )
    end
    let(:source_archive) { Archive.new("source.git", default_branch: runner.branch) }
    let(:a_release) { double(:a_release) }
    let(:another_release) { double(:another_release) }

    let(:instance) do
      described_class.new(
        name: name,
        infrastructure_archive: infra_archive,
        deploy_archive: deploy_archive,
        source_archive: source_archive,
        releases: [a_release]
      )
    end

    before(:each) { Fauxpaas.git_runner = runner }

    describe "#signature" do
      context "when no commitish given" do
        it "returns the latest release signature" do
          expect(instance.signature).to eql(
            ReleaseSignature.new(
              infrastructure: infra_archive.latest,
              deploy: deploy_archive.latest,
              source: source_archive.latest
            )
          )
        end
      end
      context "when commitish given" do
        it "returns an appropriate signature" do
          expect(instance.signature(runner.short)).to eql(
            ReleaseSignature.new(
              infrastructure: infra_archive.latest,
              deploy: deploy_archive.latest,
              source: source_archive.reference(runner.short)
            )
          )
        end
      end
    end

    describe "#release" do
      let(:signature) do
        ReleaseSignature.new(
          infrastructure: infra_archive.latest,
          deploy: deploy_archive.latest,
          source: source_archive.latest
        )
      end
      it "builds the release that corresponds to the signature" do
        expect(instance.release(signature)).to eql(
          Release.new(
            source: signature.source,
            infrastructure: infra_archive.infrastructure(signature.infrastructure),
            deploy_config: deploy_archive.deploy_config(signature.deploy)
          )
        )
      end
    end

    describe "#name" do
      it "returns the name" do
        expect(instance.name).to eql(name)
      end
    end

    describe "#app" do
      it "returns the app" do
        expect(instance.app).to eql(app)
      end
    end

    describe "#stage" do
      it "returns the stage" do
        expect(instance.stage).to eql(stage)
      end
    end

    describe "#default_branch" do
      it "returns the branch" do
        expect(instance.default_branch).to eql(runner.branch)
      end
      it "can be set" do
        instance.default_branch = "newbranch"
        expect(instance.default_branch).to eql("newbranch")
      end
    end

    describe "#releases #log_release" do
      it "returns logged releases" do
        instance.log_release(another_release)
        expect(instance.releases).to contain_exactly(a_release, another_release)
      end
    end

  end
end
