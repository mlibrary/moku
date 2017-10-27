require_relative "./spec_helper"
require "fauxpaas/capistrano_deployer"

module Fauxpaas
  RSpec.describe CapistranoDeployer do
    RSpec::Matchers.define_negated_matcher :a_string_not_matching, :a_string_matching

    let(:success) { double(:success, success?: true) }
    let(:failure) { double(:failure, success?: false) }
    let(:path) { "/base/path" }
    let(:kernel) { double(:kernel, capture3: ["", "", success]) }

    class TestInstance
      def initialize(*args)
        @releases = []
      end

      attr_reader :releases

      def name 
        "myapp_staging" 
      end

      def deployer_env 
        "rails" 
      end

      def default_branch
        "develop"
      end

      def log_release(release)
        @releases << release
      end
    end

    class TestRelease < OpenStruct
      def initialize(rev)
        super()
        self.src=rev
      end
    end

    let(:instance) { TestInstance.new }

    let(:deployer) { described_class.new(path, kernel) }

    describe "#deploy" do
      let(:commit) { "031d744fe4228d2440830d59d070a8598ac19da0" }
      let(:cap_stderr) { "Branch master (at #{commit}) deployed as release 20171024181746 by fauxpaas"}

      context "when capistrano prints the revision message" do
        let(:kernel) { double(:kernel, capture3: ["", cap_stderr, success]) }

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

        it "logs the release" do
          deployer.deploy(instance, release: TestRelease)
          expect(instance.releases).to contain_exactly(an_instance_of(TestRelease))
        end

        it "by default, logs a Release with the current commit" do
          deployer.deploy(instance, release: TestRelease)
          expect(instance.releases.first.src).to eq(commit)
        end
      end

      context "when the deployment fails" do
        let(:kernel) { double(:kernel, capture3: ["", "", failure]) }
        it "does not log the release" do
          deployer.deploy(instance, release: TestRelease)
          expect(instance.releases.length).to eq(0)
        end
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
