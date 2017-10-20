require_relative "./spec_helper"
require "fauxpaas/capistrano_deployer"

module Fauxpaas
  RSpec.describe CapistranoDeployer do

    let(:success) { double(:success, success?: true) }
    let(:failure) { double(:failure, success?: false) }
    let(:path) { "/base/path" }
    let(:kernel) { double(:kernel, capture3: ["", "", success]) }

    let(:instance) do
      double(:instance,
        name: "myapp-staging",
        deployer_env: "rails",
        default_branch: "develop")
    end

    let(:deployer) { described_class.new(path, kernel) }

    describe "#deploy" do
      it "gets the default from the instance" do
        expect(kernel).to receive(:capture3)
          .with("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} deploy BRANCH=#{instance.default_branch}")
        deployer.deploy(instance)
      end

      it "deploys the given branch or commit" do
        expect(kernel).to receive(:capture3)
          .with("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} deploy BRANCH=master")
        deployer.deploy(instance, reference: "master")
      end
    end

    describe "#caches" do
      it "invokes capistrano" do
        expect(kernel).to receive(:capture3)
          .with("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} caches:list")
        deployer.caches(instance)
      end
    end

  end
end
