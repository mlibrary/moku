# frozen_string_literal: true

require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "moku/instance"
require "moku/archive_reference"
require "moku/release_signature"
require "pathname"

module Moku
  RSpec.describe Instance do
    R = Struct.new(:id)
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
    let(:infrastructure) { ArchiveReference.new("infra.git", runner.branch, runner) }
    let(:dev) { ArchiveReference.new("dev.git", runner.branch, runner) }
    let(:deploy) { ArchiveReference.new("deploy.git", runner.branch, runner) }
    let(:source) { ArchiveReference.new("source.git", runner.branch, runner) }
    let(:releases) { [a_release] }
    let(:a_release) { double(:a_release, id: "1") }

    let(:instance) do
      described_class.new(
        name: name,
        infrastructure: infrastructure,
        dev: dev,
        deploy: deploy,
        source: source,
        releases: releases
      )
    end

    let(:runner) { SpoofedGitRunner.new }

    describe "#signature" do
      context "when no commitish given" do
        it "returns the latest release signature" do
          expect(instance.signature).to eql(
            ReleaseSignature.new(
              infrastructure: infrastructure.latest,
              dev: dev.latest,
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
              infrastructure: infrastructure.latest,
              dev: dev.latest,
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


    describe "#releases" do
      let(:releases) { [R.new(1), R.new(2), R.new(3), R.new(4), R.new(5), R.new(6)].shuffle }

      it "sorts the releases" do
        expect(instance.releases).to eql(
          [R.new(6), R.new(5), R.new(4), R.new(3), R.new(2), R.new(1)]
        )
      end
    end

    describe "#log_releases" do
      let(:releases) { [a_release] }
      let(:another_release) { double(:another_release, id: "2") }

      it "returns logged releases" do
        instance.log_release(another_release)
        expect(instance.releases).to contain_exactly(a_release, another_release)
      end

    end

    describe "#caches" do
      context "with >= 5 releases" do
        let(:releases) { [R.new(1), R.new(2), R.new(3), R.new(4), R.new(5), R.new(6)].shuffle }

        it "returns the last five releases" do
          expect(instance.caches).to eql(
            [R.new(6), R.new(5), R.new(4), R.new(3), R.new(2)]
          )
        end
      end

      context "with < 5 releases" do
        let(:releases) { [R.new(3), R.new(1), R.new(2)] }

        it "returns all releases" do
          expect(instance.caches).to eql(
            [R.new(3), R.new(2), R.new(1)]
          )
        end
      end
    end
  end
end
