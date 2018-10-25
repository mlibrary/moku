# frozen_string_literal: true

require_relative "command_helper"
require_relative "../support/a_command"
require "fauxpaas/command/set_default_branch"

module Fauxpaas
  RSpec.describe Command::SetDefaultBranch do
    include_context "when running a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        new_branch: "new_branch"
      )
    end

    it_behaves_like "a command"

    it "action is :set_default_branch" do
      expect(command.action).to be(:set_default_branch)
    end

    describe "#instance_repo" do
      it "returns the repo" do
        expect(command.instance_repo).to eql(Fauxpaas.instance_repo)
      end
    end
  end

end
