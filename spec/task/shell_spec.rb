# frozen_string_literal: true

require "moku/task/shell"
require "fileutils"
require "pathname"
require "pp"
require "fakefs/spec_helpers"

module Moku
  RSpec.describe Task::Shell do
    include FakeFS::SpecHelpers
    let(:path) { Pathname.new("/some/path") }
    let(:artifact) { double(:artifact, path: path, run: status) }
    let(:status) { double(:status, success?: true, error: "") }
    let(:command) { "some command -f -a - p" }
    let(:task) { described_class.new(command: command) }

    before(:each) do
      FileUtils.mkdir_p path.to_s
      allow(artifact).to receive(:with_env).and_yield
    end

    describe "#call" do
      it "runs the command" do
        expect(artifact).to receive(:run).with(command)
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
