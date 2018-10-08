# frozen_string_literal: true

require_relative "command_helper"
require_relative "../support/a_command"
require "fauxpaas/command/read_default_branch"

module Fauxpaas
  RSpec.describe Command::ReadDefaultBranch do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
      )
    end
    it_behaves_like "a command"

    it "action is :read_default_branch" do
      expect(command.action).to eql(:read_default_branch)
    end

    describe "#execute" do
      let(:instance) do
        double(:instance,
               default_branch: "master")
      end

      # TODO: convert this to print to stdout, inserted via stringio
      it "logs the default branch" do
        expect(Fauxpaas.logger).to receive(:info).with("Default branch: master")
        command.execute
      end
    end
  end

end
