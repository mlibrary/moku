# frozen_string_literal: true

require "moku/task/shell"
require "fileutils"
require "pathname"
require "pp"
require "fakefs/spec_helpers"

module Moku
  RSpec.describe Task::Shell do
    include FakeFS::SpecHelpers
    let(:runner) { double(:runner, run: status) }
    let(:path) { Pathname.new("/some/path") }
    let(:artifact) { double(:artifact, path: path) }
    let(:status) { double(:status, success?: true, error: "") }
    let(:command) { "some command -f -a - p" }
    let(:task) { described_class.new(command: command, runner: runner) }

    before(:each) do
      FileUtils.mkdir_p path.to_s
      allow(artifact).to receive(:with_env).and_yield
    end

    describe "#call" do
      it "runs the command" do
        expect(runner).to receive(:run).with(command)
        task.call(artifact)
      end

      it "uses the target's bundle context" do
        expect(artifact).to receive(:with_env)
        task.call(artifact)
      end

      context "when successful" do
        let(:status) { double(:status, success?: true, error: "") }

        it "returns success" do
          expect(task.call(artifact)).to eql(status)
        end
      end

      context "when unsuccessful" do
        let(:status) { double(:status, success?: false, error: "stderr") }

        it "returns failure" do
          expect(task.call(artifact)).to eql(status)
        end
      end
    end
  end
end
