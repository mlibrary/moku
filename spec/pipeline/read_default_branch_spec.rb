# frozen_string_literal: true

require "fauxpaas/pipeline/read_default_branch"

module Fauxpaas
  RSpec.describe Pipeline::ReadDefaultBranch do
    let(:logger) { double(:logger, info: nil) }
    let(:instance) { double(:instance, default_branch: "master") }
    let(:user) { "someuser" }
    let(:command) do
      double(
        instance: instance,
        user: user,
        logger: logger
      )
    end
    let(:pipeline) { described_class.new(command) }

    describe "#call" do
      it "logs the default branch" do
        expect(logger).to receive(:info).with("Default branch: master")
        pipeline.call
      end
    end
  end

end
