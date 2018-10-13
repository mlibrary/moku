# frozen_string_literal: true

require_relative "command_helper"
require_relative "../support/a_command"
require "fauxpaas/command/deploy"
require "fauxpaas/deploy_config"
require "fauxpaas/release"
require "ostruct"

module Fauxpaas
  RSpec.describe Command::Deploy do
    include_context "when running a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        reference: nil
      )
    end

    it_behaves_like "a command"

    it "action is :deploy" do
      expect(command.action).to be(:deploy)
    end
  end

end
