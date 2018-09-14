# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/deploy"
require "fauxpaas/deploy_config"
require "fauxpaas/release"
require "ostruct"

module Fauxpaas
  RSpec.describe Commands::Deploy do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        reference: nil
      )
    end
    it_behaves_like "a command"

    it "action is :deploy" do
      expect(command.action).to eql(:deploy)
    end

    describe "#execute" do
      let(:release) { double(:release, deploy: status) }
      let(:artifact) { double(:artifact) }
      let(:deploy_config) { double(:deploy_config) }
      let(:signature) { double(:signature, deploy: double(:deploy_ref)) }
      let(:instance) do
        double(
          :instance,
          name: "something",
          default_branch: "master",
          interrogator: double(:interrogator,
                               deploy: OpenStruct.new(success?: true),
                               restart: OpenStruct.new(success?: true)),
        source: double(:source, latest: double(:latest)),
        log_release: true,
        signature: signature,
        releases: ["one", "two", "three"]
        )
      end
      before(:each) do
        allow(Fauxpaas.artifact_builder).to receive(:build).with(signature)
          .and_return(artifact)
        allow(DeployConfig).to receive(:from_ref).with(signature.deploy, Fauxpaas.ref_repo)
          .and_return(deploy_config)
        allow(Release).to receive(:new).with(artifact: artifact, deploy_config: deploy_config)
          .and_return(release)
      end
      context "when it succeeds" do
        let(:status) { double(:status, success?: true) }
        it "tells cap to deploy" do
          expect(release).to receive(:deploy)
          command.execute
        end
        it "tells cap to restart" do
          expect(instance.interrogator).to receive(:restart)
          command.execute
        end
        it "saves the release" do
          expect(instance).to receive(:log_release)
          expect(instance_repo).to receive(:save_releases).with(instance)
          command.execute
        end
        it "reports success" do
          command.execute
          Fauxpaas.log_file.rewind
          expect(Fauxpaas.log_file.read).to match(/deploy successful/)
        end
      end
      context "when it fails to deploy" do
        let(:status) { double(:status, success?: false) }
        it "doesn't restart the application" do
          expect(instance.interrogator).to_not receive(:restart)
          command.execute
        end
      end
    end
  end

end
