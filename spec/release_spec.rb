# frozen_string_literal: true

require "fauxpaas/release"
require "fauxpaas/shell/basic"
require "fauxpaas/sites"
require_relative "support/fake_remote_runner"

module Fauxpaas
  # class FakeWorkingDir
  #   def initialize(dir, files)
  #     @dir = dir
  #     @files = files
  #   end
  #   attr_reader :dir
  #   def relative_files
  #     @files
  #   end
  # end

  RSpec.describe Release do
    let(:deploy_dir) { Pathname.new("/deploy/dir") }
    let(:artifact) { double(:artifact, path: "somepath") }
    let(:remote_runner) { FakeRemoteRunner.new(Shell::Basic.new) }
    let(:user) { "faux" }
    let(:sites) { Sites.new({ "site1" => ["host1"], "site2" => ["host2"] }) }
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
      it "mints a unique id" do
        one = described_class.new(
          artifact: artifact,
          deploy_config: deploy_config,
          remote_runner: remote_runner,
          user: user
        )
        sleep 0.002
        two = described_class.new(
          artifact: artifact,
          deploy_config: deploy_config,
          remote_runner: remote_runner,
          user: user
        )
        expect(one.id).to_not eql(two.id)
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
        Sites.new({
          "site1" => ["host1", "host2"],
          "site2" => ["host3", "host4"]
        })
      end

      describe "#run_per_host" do
        it "runs the command at each host" do
          %w{host1 host2 host3 host4}.each do |hostname|
            expect(remote_runner)
              .to receive(:run).with(user: user, host: hostname, command: /#{command}/)
          end
          release.run_per_host(command)
        end
      end

      describe "#run_per_site" do
        it "runs the command at one host per site" do
          %w{host1 host3}.each do |hostname|
            expect(remote_runner)
              .to receive(:run).with(user: user, host: hostname, command: /#{command}/)
          end
          release.run_per_host(command)
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
