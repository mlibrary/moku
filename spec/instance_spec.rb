require_relative "./spec_helper"
require "fauxpaas/instance"
require "pathname"

module Fauxpaas
  RSpec.describe Instance do

    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:name) { "#{app}-#{stage}" }
    let(:deployer_env) { double(:deployer_env) }
    let(:instance) do
      described_class.new(
        name: name,
        deployer_env: deployer_env
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

  end
end
