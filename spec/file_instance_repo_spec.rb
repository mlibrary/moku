# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/file_instance_repo"
require "fauxpaas/instance"
require "fauxpaas/archive"
require "fauxpaas/logged_release"

module Fauxpaas

  RSpec.describe FileInstanceRepo do
    let(:repo) { described_class.new("/instances", MemoryFilesystem.new) }

    let(:deploy_archive) { Archive.new("https://example.com/me.git", SpoofedGitRunner.new) }
    let(:infra_archive) { double(:infra_archive) }
    let(:source_archive) { double(:source_archive) }
    let(:release) { double(:release) }
    let(:instance) do
      Instance.new(
        name: "myapp-mystage",
        deploy_archive: deploy_archive,
        infrastructure_archive: infra_archive,
        source_archive: source_archive,
        releases: [release]
      )
    end

    before(:each) do
      allow(deploy_archive).to receive(:to_hash).and_return({deploy: "hash"})
      allow(infra_archive).to receive(:to_hash).and_return({infra: "hash"})
      allow(source_archive).to receive(:to_hash).and_return({source: "hash"})
      allow(Archive).to receive(:from_hash).with({deploy: "hash"}).and_return(deploy_archive)
      allow(Archive).to receive(:from_hash).with({infra: "hash"}).and_return(infra_archive)
      allow(Archive).to receive(:from_hash).with({source: "hash"}).and_return(source_archive)
      allow(release).to receive(:to_hash).and_return({release: 1})
      allow(LoggedRelease).to receive(:from_hash).with({release: 1}).and_return(release)
    end

    it "can save and find instances" do
      repo.save(instance)
      expect(repo.find(instance.name)).to eql(instance)
    end

  end
end
