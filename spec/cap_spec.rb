require_relative "./spec_helper"
require "fauxpaas/components"
require "fauxpaas/cap"

module Fauxpaas
  RSpec.describe Cap do
    let(:capfile_path) { "/capfiles/rails.capfile" }
    let(:stage) { "myapp-staging" }
    let(:backend_runner) { double(:backend_runner) }
    let(:cap) { described_class.new(capfile_path, stage, backend_runner) }

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

      it "runs the 'caches:list' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, "caches:list", anything)
        cap.caches
      end

      it "sets no options" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, {})
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
