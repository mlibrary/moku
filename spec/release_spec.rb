# frozen_string_literal: true

require_relative "spec_helper"
require "moku/release"
require "moku/sites"

module Moku
  RSpec.describe Release do
    let(:deploy_dir) { Pathname.new("/deploy/dir") }
    let(:artifact) { double(:artifact, path: "somepath") }
    let(:sites) { Sites.for("site1" => ["host1"], "site2" => ["host2"]) }
    let(:deploy_config) do
      double(
        :deploy_config,
        deploy_dir: deploy_dir,
        systemd_services: ["svc1", "svc2"],
        sites: sites,
        env: { rack_env: "staging" }
      )
    end
    let(:release) do
      described_class.new(
        artifact: artifact,
        deploy_config: deploy_config
      )
    end

    describe "#id" do
      let(:release_proc) do
        proc do
          described_class.new(
            artifact: artifact,
            deploy_config: deploy_config
          )
        end
      end

      it "mints a unique id" do
        one = release_proc.call
        sleep 0.002
        two = release_proc.call
        expect(one.id).not_to eql(two.id)
      end
    end

    describe "#path" do
      it { expect(release.path).to eql(artifact.path) }
    end

    describe "#releases_path" do
      it { expect(release.releases_path).to eql(deploy_dir/"releases") }
    end

    describe "#deploy_path" do
      it { expect(release.deploy_path).to eql(deploy_dir/"releases"/release.id) }
    end

    describe "#app_path" do
      it { expect(release.app_path).to eql(deploy_dir/"current") }
    end

    describe "#systemd_services" do
      it { expect(release.systemd_services).to contain_exactly("svc1", "svc2") }
    end

    describe "#sites" do
      it { expect(release.sites).to eql(deploy_config.sites) }
    end

    describe "#env" do
      it { expect(release.env).to eql(deploy_config.env) }
    end

    describe "#run" do
      xit "see Shell::RemoteRelease"
    end
  end
end
