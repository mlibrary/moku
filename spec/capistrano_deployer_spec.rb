require_relative "./spec_helper"
require "fauxpaas/capistrano_deployer"

module Fauxpaas
  RSpec.describe CapistranoDeployer do

    let(:path) { "/base/path" }
    let(:kernel) { double(:kernel, system: nil) }

    let(:instance) do
      double(:instance, name: "myapp-staging", deployer_env: "rails")
    end

    let(:deployer) { described_class.new(path, kernel) }

    describe "#deploy" do
      it "invokes capistrano and deploys the master branch" do
        expect(kernel).to receive(:system)
          .with("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} deploy BRANCH=master")
        deployer.deploy(instance)
      end

      it "can invoke capistrano with an arbitrary branch/revision" do
        expect(kernel).to receive(:system)
          .with("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} deploy BRANCH=deadbeef")
        deployer.deploy(instance,branch: 'deadbeef')
      end
    end

  end
end
