# frozen_string_literal: true

require "moku/task/bundle"
require "fileutils"
require "pathname"
require "fakefs/spec_helpers"

module Moku
  RSpec.describe Task::Bundle do
    include FakeFS::SpecHelpers
    let(:runner) { double(:runner, run: status) }
    let(:task) { described_class.new(runner: runner) }
    let(:path) { Pathname.new("/some/path") }
    let(:artifact) { double(:artifact, path: path) }
    let(:status) { double(:status, success?: true, error: "") }

    before(:each) do
      FileUtils.mkdir_p path.to_s
      allow(artifact).to receive(:with_env).and_yield
    end

    describe "#call" do
      it "runs the bundle command" do
        expect(runner).to receive(:run).with(/bundle install/)
        task.call(artifact)
      end

      it "uses the target's bundle context" do
        expect(artifact).to receive(:with_env)
        task.call(artifact)
      end

      it "returns the status" do
        expect(task.call(artifact)).to eql(status)
      end
    end
  end
end
