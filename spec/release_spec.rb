# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/release"
require "fauxpaas/shell/basic"
require "fauxpaas/sites"

module Fauxpaas
  RSpec.describe Release do
    let(:deploy_dir) { Pathname.new("/deploy/dir") }
    let(:artifact) { double(:artifact, path: "somepath") }
    let(:remote_runner) { FakeRemoteRunner.new(Shell::Basic.new) }
    let(:user) { "faux" }
    let(:sites) { Sites.new("site1" => ["host1"], "site2" => ["host2"]) }
    let(:deploy_config) do
      double(
        :deploy_config,
        deploy_dir: deploy_dir,
        systemd_services: ["svc1", "svc2"],
        sites: sites,
        shell_env: "SHELL=env"
      )
    end
    let(:release) do
      described_class.new(
        artifact: artifact,
        deploy_config: deploy_config,
        remote_runner: remote_runner,
        user: user
      )
    end

    describe "#id" do
      let(:release_proc) do
        proc do
          described_class.new(
            artifact: artifact,
            deploy_config: deploy_config,
            remote_runner: remote_runner,
            user: user
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

    describe "#deploy_path" do
      it { expect(release.deploy_path).to eql(deploy_dir/"releases"/release.id) }
    end

    describe "#app_path" do
      it { expect(release.app_path).to eql(deploy_dir/"current") }
    end

    describe "#systemd_services" do
      it { expect(release.systemd_services).to contain_exactly("svc1", "svc2") }
    end

    describe "running on remote hosts" do
      let(:remote_runner) { double(:remote_runner, run: double(:status, success?: true)) }
      let(:command) { "somecommand" }
      let(:sites) do
        Sites.new(
          "site1" => ["host1", "host2"],
          "site2" => ["host3", "host4"]
        )
      end

      describe "#run_per_host" do
        it "runs the command at each host" do
          ["host1", "host2", "host3", "host4"].each do |hostname|
            expect(remote_runner)
              .to receive(:run).with(user: user, host: hostname, command: /#{command}/)
            release.run_per_host(command)
          end
        end
      end

      describe "#run_per_site" do
        it "runs the command at one host per site" do
          ["host1", "host3"].each do |hostname|
            expect(remote_runner)
              .to receive(:run).with(user: user, host: hostname, command: /#{command}/)
            release.run_per_host(command)
          end
        end
      end

      describe "#run_per_deploy" do
        it "runs the command at exactly one host" do
          expect(remote_runner)
            .to receive(:run).with(user: user, host: "host1", command: /#{command}/)
          release.run_per_host(command)
        end
      end
    end
  end
end
