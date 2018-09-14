# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/rollback"

module Fauxpaas

  RSpec.describe Commands::Rollback, skip: true do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        cache: "foo"
      )
    end
    it_behaves_like "a command"

    it "action is :rollback" do
      expect(command.action).to eql(:rollback)
    end

    describe "#execute" do
      let(:instance) do
        double(:instance,
               interrogator: double(:interrogator,
                                    rollback: OpenStruct.new(success?: true)),
        source: double(:source,
                       latest: "latest_source"))
      end
      it "tells cap to rollback" do
        expect(instance.interrogator).to receive(:rollback)
          .with(instance.source.latest, "foo")
        command.execute
      end
    end
  end

end
