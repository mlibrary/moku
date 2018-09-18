# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/deploy"
require "fauxpaas/deploy_config"
require "fauxpaas/release"
require "ostruct"

module Fauxpaas
  RSpec.describe Commands::Deploy do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        reference: nil
      )
    end
    it_behaves_like "a command"

    it "action is :deploy" do
      expect(command.action).to eql(:deploy)
    end
  end

end
