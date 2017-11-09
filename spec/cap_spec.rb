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
    let(:cap) { described_class.new(capfile_path, stage, backend_runner, fs) }

    describe "#deploy" do
      let(:infrastructure) { double(:infrastructure, to_hash: {infra: 5}) }
      it "writes the infrastructure in a temporary dir" do
        allow(backend_runner).to receive(:run)
        expect(fs).to receive(:write).with(
          fs.tmpdir + "infrastructure.yml",
          YAML.dump(infrastructure.to_hash)
        )
        cap.deploy(infrastructure, {})
      end

      it "passes the capfile_path" do
        expect(backend_runner).to receive(:run)
          .with(capfile_path, anything, anything, anything)
        cap.deploy(infrastructure, {})
      end

      it "uses name as the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, stage, anything, anything)
        cap.deploy(infrastructure, {})
      end

      it "runs the 'deploy' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, "deploy", anything)
        cap.deploy(infrastructure, {})
      end

      it "sets :infrastructure_config_path" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          infrastructure_config_path: (fs.tmpdir + "infrastructure.yml").to_s
        ))
        cap.deploy(infrastructure, {foo: "bar"})
      end

      it "sets :application to the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          application: stage,
        ))
        cap.deploy(infrastructure, {foo: "bar"})
      end

      it "sets the passed options" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            { foo: "bar", baz: "buzz" }
        ))
        cap.deploy(infrastructure, {foo: "bar", baz: "buzz"})
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

      it "passes the capfile_path" do
        expect(backend_runner).to receive(:run)
          .with(capfile_path, anything, anything, anything)
        cap.caches
      end

      it "uses name as the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, stage, anything, anything)
        cap.caches
      end

      it "sets :application to the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          application: stage,
        ))
        cap.caches
      end

      it "runs the 'caches:list' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, "caches:list", anything)
        cap.caches
      end

      it "returns a list of caches" do
        allow(backend_runner).to receive(:run)
          .and_return(["", stderr, ""])
        expect(cap.caches).to eql(["onecache", "twocache", "threecache"])
      end
    end


    describe "#rollback" do
      let(:cache) { "20160614133327" }

      it "passes the capfile_path" do
        expect(backend_runner).to receive(:run)
          .with(capfile_path, anything, anything, anything)
        cap.rollback(cache)
      end

      it "uses name as the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, stage, anything, anything)
        cap.rollback(cache)
      end

      it "sets :application to the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
          application: stage,
        ))
        cap.rollback(cache)
      end

      it "runs the 'deploy:rollback' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, "deploy:rollback", anything)
        cap.rollback(cache)
      end

      it "sets :rollback_release" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including({rollback_release: cache }))
        cap.rollback(cache)
      end
    end

  end
end
