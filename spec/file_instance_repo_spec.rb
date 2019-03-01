# frozen_string_literal: true

require_relative "./support/spoofed_git_runner"
require "fakefs/spec_helpers"
require "moku/config"
require "moku/file_instance_repo"
require "yaml"

module Moku
  RSpec.describe FileInstanceRepo do
    let(:instance_root) { Moku.root/"spec"/"fixtures"/"unit"/"instances" }
    let(:releases_root) { Moku.root/"spec"/"fixtures"/"unit"/"releases" }
    let(:branches_root) { Moku.root/"spec"/"fixtures"/"unit"/"branches-cache" }
    let(:git_runner) { SpoofedGitRunner.new }
    let(:static_repo) do
      described_class.new(
        instances_path: instance_root,
        releases_path: releases_root,
        branches_path: branches_root,
        git_runner: git_runner
      )
    end
    let(:tmp_repo) do
      described_class.new(
        instances_path: "/instances",
        releases_path: "/releases",
        branches_path: "/branches",
        git_runner: git_runner
      )
    end

    before(:each) do
      Moku.config.register(:git_runner) { git_runner }
    end

    describe "#find" do
      context "when finding non-legacy instances" do
        let(:instance) { static_repo.find("test-persistence") }

        it { expect(instance.deploy.url).to   eql("git@github.com:mlibrary/moku-deploy") }
        it { expect(instance.source.url).to   eql("https://github.com/dpn-admin/dpn-client.git") }
        it { expect(instance.infrastructure.url).to eql("git@github.com:mlibrary/moku-infrastructure") }
        it { expect(instance.dev.url).to eql("git@github.com:mlibrary/moku-dev") }
        it { expect(instance.deploy.commitish).to   eql("test-norails") }
        it { expect(instance.source.commitish).to   eql("master") }
        it { expect(instance.infrastructure.commitish).to eql("test-norails") }
        it { expect(instance.dev.commitish).to eql("test-norails") }
      end
    end

    describe "#save_releases" do
      include FakeFS::SpecHelpers
      let(:instance) { static_repo.find("test-persistence") }
      before(:each) do
        FakeFS::FileSystem.clone(releases_root)
        FakeFS::FileSystem.clone(instance_root)
        FakeFS::FileSystem.clone(branches_root)
      end

      it "can save releases" do
        contents_before = YAML.load(File.read(releases_root/"test-persistence.yml"))
        tmp_repo.save_releases(instance)
        expect(YAML.load(File.read("/releases/test-persistence.yml"))).to eql(contents_before)
      end

      it "creates the directories to save in" do
        tmp_repo.save_releases(instance)
        expect(releases_root.exist?).to be true
      end
    end
  end
end
