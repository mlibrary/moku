require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require "fauxpaas/components"
require "fauxpaas/cap"

module Fauxpaas
  RSpec.describe Cap do
    let(:capfile_path) { "/capfiles/rails.capfile" }
    let(:stage) { "myapp-staging" }
    let(:backend_runner) { double(:backend_runner) }
    let(:fs) { MemoryFilesystem.new }
    let(:options) do
      {
        appname: stage,
        deploy_dir: "/some/dir",
        deployer_env: capfile_path,
        rails_env: "prod",
        assets_prefix: "assets"
      }
    end
    let(:cap) { described_class.new(options, stage, backend_runner, fs) }

    RSpec.shared_examples "a cap task" do
      it "passes the capfile_path" do
        expect(backend_runner).to receive(:run)
          .with(capfile_path, anything, anything, anything)
        subject
      end
      it "uses name as the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, stage, anything, anything)
        subject
      end
      it "sets :application" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          application: options[:appname],
        ))
        subject
      end
      it "sets :deploy_dir" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          deploy_dir: options[:deploy_dir],
        ))
        subject
      end
      it "sets :rails_env" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          rails_env: options[:rails_env],
        ))
        subject
      end
      it "sets :assets_prefix" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          assets_prefix: options[:assets_prefix],
        ))
        subject
      end
    end

    describe "#deploy" do
      let(:infrastructure) { double(:infrastructure, to_hash: {infra: 5}) }
      let(:source) { double(:source, url: "someurl", reference: "someref") }
      subject { cap.deploy(infrastructure, source) }

      it_behaves_like "a cap task"

      it "writes the infrastructure in a temporary dir" do
        allow(backend_runner).to receive(:run)
        expect(fs).to receive(:write).with(
          fs.tmpdir + "infrastructure.yml",
          YAML.dump(infrastructure.to_hash)
        )
        subject
      end

      it "runs the 'deploy' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, "deploy", anything)
        subject
      end

      it "sets :infrastructure_config_path" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          infrastructure_config_path: (fs.tmpdir + "infrastructure.yml").to_s
        ))
        subject
      end
    end

    describe "#caches" do
      let(:stderr) do
        "#{Fauxpaas.split_token}\n" \
          "onecache\ntwocache\nthreecache\n" \
          "#{Fauxpaas.split_token}\n"
      end

      before(:each) do
        allow(backend_runner).to receive(:run)
          .and_return(["", stderr, :status])
      end

      subject { cap.caches }

      it_behaves_like "a cap task"

      it "runs the 'caches:list' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, "caches:list", anything)
        subject
      end

      it "returns a list of caches" do
        allow(backend_runner).to receive(:run)
          .and_return(["", stderr, ""])
        expect(subject).to eql(["onecache", "twocache", "threecache"])
      end
    end


    describe "#rollback" do
      let(:source) { double(:source, url: "someurl", reference: "someref") }
      let(:cache) { "20160614133327" }

      subject { cap.rollback(source, cache) }

      it_behaves_like "a cap task"

      it "runs the 'deploy:rollback' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, "deploy:rollback", anything)
        subject
      end

      it "sets :rollback_release" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including({rollback_release: cache }))
        subject
      end
    end

  end
end
