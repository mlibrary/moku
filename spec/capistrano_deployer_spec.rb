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
      it "invokes capistrano" do
        expect(kernel).to receive(:system)
          .with("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} deploy")
        deployer.deploy(instance)
      end
    end

  end
end
