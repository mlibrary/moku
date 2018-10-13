# frozen_string_literal: true

require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/instance"
require "fauxpaas/archive_reference"
require "fauxpaas/release_signature"
require "pathname"

module Fauxpaas
  RSpec.describe Instance do
    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:name) { "#{app}-#{stage}" }

    let(:deploy_content) do
      {
        "appname"      => name,
        "deployer_env" => "foo.capfile",
        "rails_env"    => "testing",
        "deploy_dir"   => "/some/deploy/dir"
      }
    end
    let(:shared) { ArchiveReference.new("infra.git", runner.branch, runner) }
    let(:unshared) { ArchiveReference.new("dev.git", runner.branch, runner) }
    let(:deploy) { ArchiveReference.new("deploy.git", runner.branch, runner) }
    let(:source) { ArchiveReference.new("source.git", runner.branch, runner) }
    let(:a_release) { double(:a_release) }
    let(:another_release) { double(:another_release) }

    let(:instance) do
      described_class.new(
        name: name,
        shared: shared,
        unshared: unshared,
        deploy: deploy,
        source: source,
        releases: [a_release]
      )
    end

    let(:runner) { SpoofedGitRunner.new }

    describe "#signature" do
      context "when no commitish given" do
        it "returns the latest release signature" do
          expect(instance.signature).to eql(
            ReleaseSignature.new(
              shared: shared.latest,
              unshared: unshared.latest,
              deploy: deploy.latest,
              source: source.latest
            )
          )
        end
      end

      context "when commitish given" do
        it "returns an appropriate signature" do
          expect(instance.signature(runner.short)).to eql(
            ReleaseSignature.new(
              shared: shared.latest,
              unshared: unshared.latest,
              deploy: deploy.latest,
              source: source.at(runner.short)
            )
          )
        end
      end
    end

    describe "#name" do
      it "returns the name" do
        expect(instance.name).to eql(name)
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
