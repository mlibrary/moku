# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/set_default_branch"

module Fauxpaas
  RSpec.describe Commands::SetDefaultBranch do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        new_branch: "new_branch"
      )
    end
    it_behaves_like "a command"

    it "action is :set_default_branch" do
      expect(command.action).to eql(:set_default_branch)
    end

    describe "#execute" do
      let(:instance) { OpenStruct.new(default_branch: "old_branch") }
      it "saves the changed branch" do
        expect(instance_repo).to receive(:save_instance)
          .with(OpenStruct.new(default_branch: "new_branch"))
        command.execute
      end
    end
  end

end
