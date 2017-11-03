# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/capistrano_deployer"

module Fauxpaas
  RSpec.describe CapistranoDeployer do

    let(:success) { double(:success, success?: true) }
    let(:failure) { double(:failure, success?: false) }
    let(:path) { "/base/path" }
    let(:runner) { double(:runner, run: ["", "", success]) }
    let(:infrastructure_config_path) { "/myapp-staging/infrastructure.path" }

    class TestInstance
      def initialize(*_args)
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

      def deploy_dir
        "/deploy/dir"
      end

      def rails_env
        "production"
      end

      def assets_prefix
        "assets"
      end

      def source_repo
        "some_source"
      end
    end

    class TestRelease < OpenStruct
      def initialize(rev)
        super()
        self.src = rev
      end
    end

    let(:instance) { TestInstance.new }

    let(:deployer) { described_class.new(path, runner) }

    describe "#deploy" do
      let(:commit) { "031d744fe4228d2440830d59d070a8598ac19da0" }
      let(:cap_stderr) { "Branch master (at #{commit}) deployed as release 20171024181746 by fauxpaas" }

      context "when capistrano prints the revision message" do
        let(:runner) { double(:runner, run: ["", cap_stderr, success]) }

        it "invokes cap deploy" do
          expect(runner).to receive(:run).with(instance.name, "deploy", anything)
          deployer.deploy(instance, infrastructure_config_path: infrastructure_config_path)
        end

        it "sets BRANCH to instance.default_branch when no reference given" do
          expect(runner).to receive(:run)
            .with(anything, anything, a_hash_including(branch: instance.default_branch) )
          deployer.deploy(instance, infrastructure_config_path: infrastructure_config_path)
        end

        it "sets BRANCH to the given reference" do
          expect(runner).to receive(:run)
            .with(anything, anything, a_hash_including(branch: "mybranch"))
          deployer.deploy(instance, reference: "mybranch", infrastructure_config_path: infrastructure_config_path)
        end

        it "logs the release" do
          deployer.deploy(instance, release: TestRelease, infrastructure_config_path: infrastructure_config_path)
          expect(instance.releases).to contain_exactly(an_instance_of(TestRelease))
        end

        it "by default, logs a Release with the current commit" do
          deployer.deploy(instance, release: TestRelease, infrastructure_config_path: infrastructure_config_path)
          expect(instance.releases.first.src).to eq(commit)
        end
      end

      context "when the deployment fails" do
        let(:runner) { double(:runner, run: ["", "", failure]) }
        it "does not log the release" do
          deployer.deploy(instance, release: TestRelease, infrastructure_config_path: infrastructure_config_path)
          expect(instance.releases.length).to eq(0)
        end
      end
    end

    describe "#rollback" do
      let(:cache) { "20160614133327" }

      it "invokes cap rollback" do
        expect(runner).to receive(:run)
          .with(instance.name, "deploy:rollback", anything)
        deployer.rollback(instance, cache: cache)
      end
      it "sets ROLLBACK_RELEASE to the given cache" do
        expect(runner).to receive(:run)
          .with(anything, anything, a_hash_including(rollback_release: cache))
        deployer.rollback(instance, cache: cache)
      end
      it "does not set ROLLBACK_RELEASE when no cache given" do
        expect(runner).to receive(:run)
          .with(anything, anything, a_hash_including(rollback_release: nil))
        deployer.rollback(instance)
      end
    end

    describe "#caches" do
      it "invokes cap caches:list" do
        expect(runner).to receive(:run)
          .with(instance.name, "caches:list", {})
        deployer.caches(instance)
      end
    end
  end
end
