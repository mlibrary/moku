# frozen_string_literal: true

require "fauxpaas/task/task"
require "pathname"

module Fauxpaas
  RSpec.describe Task::Task do
    class TestTask < described_class
      def test_with_env(path)
        with_env(path) { yield }
      end
    end

    describe "#with_env" do
      let(:path) { Pathname.new(ENV["HOME"]) }
      let(:task) { TestTask.new }

      it "runs the command in the directory" do
        result = task.test_with_env(path) { Dir.pwd }
        expect(result.strip).to eql(path.to_s)
      end

      it "sheds the bundler context" do
        expect(Bundler).to receive(:with_clean_env).and_call_original
        task.test_with_env(path) { 1 }
      end
    end
  end
end
