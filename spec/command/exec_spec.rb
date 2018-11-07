# frozen_string_literal: true

require_relative "command_helper"
require_relative "../support/a_command"
require "moku/command/exec"

module Moku

  RSpec.describe Command::Exec do
    include_context "when running a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        cmd: "ls",
        per: "deploy"
      )
    end

    it_behaves_like "a command"

    it "action is :exec" do
      expect(command.action).to be(:exec)
    end
  end

end
