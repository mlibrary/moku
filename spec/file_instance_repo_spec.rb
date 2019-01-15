# frozen_string_literal: true

require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "moku/config"
require "moku/filesystem"
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
        filesystem: Filesystem.new,
        git_runner: git_runner
      )
    end
    let(:mem_fs) { MemoryFilesystem.new }
    let(:tmp_repo) do
      described_class.new(
        instances_path: "/instances",
        releases_path: "/releases",
        branches_path: "/branches",
        filesystem: mem_fs,
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
        it { expect(instance.infrastructure.url).to   eql("git@github.com:mlibrary/moku-infrastructure") }
        it { expect(instance.dev.url).to eql("git@github.com:mlibrary/moku-dev") }
        it { expect(instance.deploy.commitish).to   eql("test-norails") }
        it { expect(instance.source.commitish).to   eql("master") }
        it { expect(instance.infrastructure.commitish).to   eql("test-norails") }
        it { expect(instance.dev.commitish).to eql("test-norails") }
      end
    end

    describe "#save_releases" do
      let(:instance) { static_repo.find("test-persistence") }

      it "can save releases" do
        contents_before = YAML.load(File.read(releases_root/"test-persistence.yml"))
        instance = static_repo.find("test-persistence")
        tmp_repo.save_releases(instance)
        expect(YAML.load(mem_fs.read("/releases/test-persistence.yml"))).to eql(contents_before)
      end

      it "creates the directories to save in" do
        expect(mem_fs).to receive(:mkdir_p).with(Pathname.new("/releases"))
        tmp_repo.save_releases(instance)
      end
    end
  end
end
