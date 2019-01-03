# frozen_string_literal: true

require "moku/task/bundle"

module Moku
  RSpec.describe Task::Bundle do
    let(:status) { double(:status) }
    let(:artifact) { double(:artifact) }
    let(:bundle) { double(:bundle, install: status) }
    let(:task) { described_class.new(cached_bundle: bundle) }

    describe "#call" do
      it "delegates to the cached bundle" do
        expect(bundle).to receive(:install).with(artifact)
        task.call(artifact)
      end

      it "returns the status from the delegation" do
        expect(task.call(artifact)).to eql(status)
      end
    end
  end
end
