require_relative "./spec_helper"
require "fauxpaas/capistrano_deployer"

module Fauxpaas
  RSpec.describe CapistranoDeployer do
    RSpec::Matchers.define_negated_matcher :a_string_not_matching, :a_string_matching

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
      it "invokes cap deploy" do
        expect(kernel).to receive(:capture3)
          .with(a_string_matching("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} deploy"))
        deployer.deploy(instance)
      end
      it "sets BRANCH to instance.default_branch when no reference given" do
        expect(kernel).to receive(:capture3)
          .with(a_string_matching("BRANCH=#{instance.default_branch}"))
        deployer.deploy(instance)
      end
      it "sets BRANCH to the given reference" do
        expect(kernel).to receive(:capture3)
          .with(a_string_matching("BRANCH=mybranch"))
        deployer.deploy(instance, reference: "mybranch")
      end
    end

    describe "#rollback" do
      let(:cache) { "20160614133327" }

      it "invokes cap rollback" do
        expect(kernel).to receive(:capture3)
          .with(a_string_matching("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} deploy:rollback"))
        deployer.rollback(instance, cache: cache)
      end
      it "sets ROLLBACK_RELEASE to the given cache" do
        expect(kernel).to receive(:capture3)
          .with(a_string_matching("ROLLBACK_RELEASE=#{cache}"))
        deployer.rollback(instance, cache: cache)
      end
      it "does not set ROLLBACK_RELEASE when no cache given" do
        expect(kernel).to receive(:capture3)
          .with(a_string_not_matching("ROLLBACK_RELEASE"))
        deployer.rollback(instance)
      end
    end

    describe "#caches" do
      it "invokes cap caches:list" do
        expect(kernel).to receive(:capture3)
          .with("cap -f #{path}/#{instance.deployer_env}.capfile #{instance.name} caches:list")
        deployer.caches(instance)
      end
    end

  end
end
