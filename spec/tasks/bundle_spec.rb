require_relative "../spec_helper"
require "fauxpaas/tasks/bundle"
require "fakefs/spec_helpers"
require "fileutils"
require "pathname"

module Fauxpaas
  RSpec.describe Tasks::Bundle do
    include FakeFS::SpecHelpers
    let(:runner) { double(:runner, run: ["stdout", "stderr", status]) }
    let(:task) { described_class.new(runner: runner) }
    let(:path) { Pathname.new("/some/path") }
    let(:artifact) { double(:artifact, path: path) }
    let(:status) { double(:status, success?: true, error: "") }

    before(:each) { FileUtils.mkdir_p path.to_s }

    describe "#call" do
      it "runs the bundle command" do
        expect(runner).to receive(:run).with(/bundle install/)
        task.call(artifact)
      end

      it "uses the target's bundle context" do
        expect(task).to receive(:with_env).and_call_original
        task.call(artifact)
      end

      it "executes in the target's dir" do
        expect(task).to receive(:with_env).with(path).and_call_original
        task.call(artifact)
      end

      context "when successful" do
        let(:status) { double(:status, success?: true, error: "") }
        it "returns success" do
          expect(task.call(artifact)).to eql(status)
        end
      end
      context "when unsuccessful" do
        let(:status) { double(:status, success?: false, error: "Failed to install gems") }
        it "returns failure" do
          expect(task.call(artifact)).to eql(status)
        end
      end

    end

  end
end
