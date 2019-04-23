# frozen_string_literal: true

require "moku/pipeline/read_default_branch"

module Moku
  RSpec.describe Pipeline::ReadDefaultBranch do
    let(:logger) { double(:logger, info: nil) }
    let(:instance) { double(:instance, default_branch: "master") }
    let(:pipeline) { described_class.new(instance: instance).tap {|p| p.logger = logger } }

    describe "#call" do
      it "logs the default branch" do
        expect(logger).to receive(:info).with("Default branch: master")
        pipeline.call
      end
    end
  end

end
