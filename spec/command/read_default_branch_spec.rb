# frozen_string_literal: true

require_relative "command_helper"
require_relative "../support/a_command"
require "fauxpaas/command/read_default_branch"

module Fauxpaas
  RSpec.describe Command::ReadDefaultBranch do
    include_context "when running a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user
      )
    end

    it_behaves_like "a command"

    it "action is :read_default_branch" do
      expect(command.action).to be(:read_default_branch)
    end
  end

end
