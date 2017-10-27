# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/instance"
require "pathname"

module Fauxpaas
  RSpec.describe Instance do
    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:name) { "#{app}-#{stage}" }
    let(:deployer_env) { double(:deployer_env) }
    let(:somebranch) { "somebranch" }
    let(:instance) do
      described_class.new(
        name: name,
        deployer_env: deployer_env,
        default_branch: somebranch
      )
    end

    describe "#name" do
      it "returns the name" do
        expect(instance.name).to eql(name)
      end
    end

    describe "#app" do
      it "returns the app" do
        expect(instance.app).to eql(app)
      end
    end

    describe "#stage" do
      it "returns the stage" do
        expect(instance.stage).to eql(stage)
      end
    end

    describe "#deployer_env" do
      it "returns the deployer_env" do
        expect(instance.deployer_env).to eql(deployer_env)
      end
    end

    describe "#default_branch" do
      it "defaults to master" do
        instance = described_class.new(
          name: "asdf",
          deployer_env: deployer_env
        )
        expect(instance.default_branch).to eql("master")
      end
      it "returns the branch" do
        expect(instance.default_branch).to eql("somebranch")
      end
      it "can be set" do
        expect { instance.default_branch = "newbranch" }
          .to change { instance.default_branch }
          .from(somebranch).to("newbranch")
      end
    end

    describe "#releases" do
      context "with an instance that was constructed with releases" do
        let(:deploy) { double("deploy1") }
        let(:instance) do
          described_class.new(
            name: name,
            deployer_env: deployer_env,
            releases: [deploy]
          )
        end
        it "returns the releases" do
          expect(instance.releases).to contain_exactly(deploy)
        end
        it "returns logged releases" do
          another_deploy = double("another_deploy")
          instance.log_release(another_deploy)
          expect(instance.releases).to contain_exactly(deploy, another_deploy)
        end
      end

      it "returns logged releases" do
        another_deploy = double("another_deploy")
        instance.log_release(another_deploy)
        expect(instance.releases).to contain_exactly(another_deploy)
      end
    end
  end
end
