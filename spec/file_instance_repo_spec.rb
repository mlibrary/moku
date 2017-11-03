# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require "fauxpaas/file_instance_repo"
require "fauxpaas/instance"
require "fauxpaas/release"
require "fauxpaas/deploy_config"

module Fauxpaas

  RSpec.describe FileInstanceRepo do
    let(:repo) { described_class.new("/instances", MemoryFilesystem.new) }

    let(:instance) do
      Instance.new(
        name: "myapp-mystage",
        source: RemoteArchive.new("myrepo.git", default_branch: "defaultbranch"),
        releases: [Release.new("https://mysrc.com")],
        deploy_config: DeployConfig.new(
          deployer_env: "rails.capfile",
          deploy_dir: "/path/to/some/dir",
          rails_env: "production",
          assets_prefix: "assets"
        )
      )
    end

    it "can save and find instances" do
      repo.save(instance)
      expect(repo.find(instance.name)).to eql(instance)
    end

  end
end
