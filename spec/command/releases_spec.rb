# frozen_string_literal: true

require_relative "command_helper"
require_relative "../support/a_command"
require "moku/command/releases"

module Moku

  RSpec.describe Command::Releases do
    include_context "when running a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user
      )
    end

    it_behaves_like "a command"

    it "action is :releases" do
      expect(command.action).to be(:releases)
    end
  end

end
