# frozen_string_literal: true

require "moku/pipeline/set_default_branch"
require "ostruct"

module Moku
  RSpec.describe Pipeline::SetDefaultBranch do
    let(:instance) { OpenStruct.new(default_branch: "old_branch") }
    let(:instance_repo) { double(:instance_repo, save_instance: nil) }
    let(:new_branch) { "new_branch" }
    let(:pipeline) do
      described_class.new(
        instance: instance,
        new_branch: new_branch,
        instance_repo: instance_repo
      )
    end

    describe "#call" do
      it "saves the changed branch" do
        expect(instance_repo).to receive(:save_instance)
          .with(OpenStruct.new(default_branch: new_branch))
        pipeline.call
      end
    end
  end

end
