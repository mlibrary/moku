require_relative "./spec_helper"
require "fauxpaas/instance"
require "pathname"

module Fauxpaas
  RSpec.describe Instance do

    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:name) { "#{app}-#{stage}" }
    let(:release_root) { "/some/release/root" }
    let(:deploy_user) { "bob" }
    let(:source) { "git@github.com:mlibrary/myapp.git" }
    let(:instance) do
      described_class.new(
        name: name,
        source: source,
        deploy_user: deploy_user,
        release_root: release_root
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

    describe "#release_root" do
      it "returns the release_root" do
        expect(instance.release_root).to eql(Pathname.new(release_root))
      end
    end

    describe "#deploy_user" do
      it "returns the deploy_user" do
        expect(instance.deploy_user).to eql(deploy_user)
      end
    end

    describe "#source" do
      it "returns the source" do
        expect(instance.source).to eql(source)
      end
    end

  end
end
