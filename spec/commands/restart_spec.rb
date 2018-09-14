# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/restart"

module Fauxpaas

  RSpec.describe Commands::Restart do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
      )
    end
    it_behaves_like "a command"

    it "action is :restart" do
      expect(command.action).to eql(:restart)
    end

    describe "#execute" do
      let(:instance) do
        double(:instance,
               interrogator: double(:interrogator,
                                    restart: OpenStruct.new(success?: true)))
      end
      it "tells cap to restart" do
        expect(instance.interrogator).to receive(:restart)
        command.execute
      end
    end
  end

end
