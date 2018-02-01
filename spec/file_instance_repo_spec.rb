# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/components/paths"
require "fauxpaas/file_instance_repo"
require "yaml"

module Fauxpaas
  RSpec.describe FileInstanceRepo do
    let(:static_repo) { described_class.new(Fauxpaas.instance_root, Fauxpaas.releases_root, Filesystem.new) }
    let(:mem_fs) { MemoryFilesystem.new }
    let(:tmp_repo) { described_class.new("/instances", "/releases", mem_fs) }

    it "can save and find instances" do
      contents_before = YAML.load(File.read(Fauxpaas.instance_root/"test-persistence"/"instance.yml"))
      instance = static_repo.find("test-persistence")
      tmp_repo.save(instance)
      expect(YAML.load(mem_fs.read("/instances/test-persistence/instance.yml"))).to eql(contents_before)
    end

    it "can save and find instances" do
      contents_before = YAML.load(File.read(Fauxpaas.releases_root/"test-persistence.yml"))
      instance = static_repo.find("test-persistence")
      tmp_repo.save(instance)
      expect(YAML.load(mem_fs.read("/releases/test-persistence.yml"))).to eql(contents_before)
    end

    it "creates the directories to save in" do
      expect(mem_fs).to receive(:mkdir_p).with(Pathname.new("/instances/test-persistence"))
      expect(mem_fs).to receive(:mkdir_p).with(Pathname.new("/releases"))

      instance = static_repo.find("test-persistence")
      tmp_repo.save(instance)
    end
  end
end
