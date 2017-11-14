# frozen_string_literal: true

require_relative "../spec_helper.rb"
require "fauxpaas/file_instance_repo"

module Fauxpaas
  RSpec.shared_context "with mocked instance repo and instance" do
    let(:mock_release) do
      instance_double(Release,
        deploy: mock_status)
    end

    let(:mock_status) do
      double(:status, success?: true)
    end

    let(:mock_source_archive) do
      instance_double(Archive,
        latest: instance_double(GitReference))
    end

    let(:mock_cap) do
      instance_double(Cap,
        rollback: mock_status,
        restart: mock_status,
        caches: "cachelist")
    end

    let(:mock_instance) do
      instance_double(Instance,
        default_branch: "oldbranch",
        source_archive: mock_source_archive,
        releases: ["one", "two", "three"],
        interrogator: mock_cap,
        release: mock_release,
        signature: nil,
        "default_branch=": nil,
        log_release: nil)
    end

    let(:mock_instance_repo) do
      instance_double(FileInstanceRepo,
        save: true,
        find: mock_instance)
    end

    before(:each) do
      Fauxpaas.instance_repo = mock_instance_repo
    end

    after(:each) do
      Fauxpaas.instance_repo = nil
    end
  end
end
