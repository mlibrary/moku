# frozen_string_literal: true

require "moku/pipeline/set_default_branch"
require "ostruct"

module Moku
  RSpec.describe Pipeline::SetDefaultBranch do
    let(:instance) { OpenStruct.new(default_branch: "old_branch") }
    let(:user) { "someuser" }
    let(:logger) { double(:logger, info: nil) }
    let(:instance_repo) { double(:instance_repo, save_instance: nil) }
    let(:command) do
      double(
        instance: instance,
        user: user,
        new_branch: "new_branch",
        instance_repo: instance_repo,
        logger: logger
      )
    end
    let(:pipeline) { described_class.new(command) }

    describe "#call" do
      it "saves the changed branch" do
        expect(instance_repo).to receive(:save_instance)
          .with(OpenStruct.new(default_branch: "new_branch"))
        pipeline.call
      end
    end
  end

end
