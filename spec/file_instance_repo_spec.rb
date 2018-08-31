# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/file_instance_repo"
require "yaml"

module Fauxpaas
  RSpec.describe FileInstanceRepo do
    let(:instance_root) { Fauxpaas.root/"spec"/"fixtures"/"unit"/"instances" }
    let(:releases_root) { Fauxpaas.root/"spec"/"fixtures"/"unit"/"releases" }
    let(:static_repo) do
      described_class.new(instance_root, releases_root, Filesystem.new, Fauxpaas.git_runner)
    end
    let(:mem_fs) { MemoryFilesystem.new }
    let(:tmp_repo) { described_class.new("/instances", "/releases", mem_fs, Fauxpaas.git_runner) }

    describe "#save_instance" do
      it "find legacy instances" do
        instance = static_repo.find("test-legacypersistence")
        tmp_repo.save_instance(instance)
        updated_contents = YAML.load(File.read(instance_root/"test-persistence"/"instance.yml"))
        expect(YAML.load(mem_fs.read("/instances/test-legacypersistence/instance.yml")))
          .to eql(updated_contents)
      end
      it "can save and find instances" do
        contents_before = YAML.load(File.read(instance_root/"test-persistence"/"instance.yml"))
        instance = static_repo.find("test-persistence")
        tmp_repo.save_instance(instance)
        expect(YAML.load(mem_fs.read("/instances/test-persistence/instance.yml")))
          .to eql(contents_before)
      end

      it "creates the directories to save in" do
        expect(mem_fs).to receive(:mkdir_p).with(Pathname.new("/instances/test-persistence"))
        instance = static_repo.find("test-persistence")
        tmp_repo.save_instance(instance)
      end
    end

    describe "#save_releases" do
      it "find legacy releases" do
        instance = static_repo.find("test-legacypersistence")
        tmp_repo.save_releases(instance)
        updated_contents = YAML.load(File.read(releases_root/"test-persistence.yml"))
        expect(YAML.load(mem_fs.read("/releases/test-legacypersistence.yml")))
          .to eql(updated_contents)
      end

      it "can save and find releases" do
        contents_before = YAML.load(File.read(releases_root/"test-persistence.yml"))
        instance = static_repo.find("test-persistence")
        tmp_repo.save_releases(instance)
        expect(YAML.load(mem_fs.read("/releases/test-persistence.yml"))).to eql(contents_before)
      end

      it "creates the directories to save in" do
        expect(mem_fs).to receive(:mkdir_p).with(Pathname.new("/releases"))
        instance = static_repo.find("test-persistence")
        tmp_repo.save_releases(instance)
      end
    end
  end
end
