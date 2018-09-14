# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/caches"

module Fauxpaas

  RSpec.describe Commands::Caches do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
      )
    end
    it_behaves_like "a command"

    it "action is :caches" do
      expect(command.action).to eql(:caches)
    end

    describe "#execute" do
      let(:instance) do
        double(:instance,
               interrogator: double(:interrogator,
                                    caches: ["cache1", "cache2"]))
      end

      # TODO: convert this to print to stdout, inserted via stringio
      it "logs the caches" do
        expect(Fauxpaas.logger).to receive(:info).with(["cache1", "cache2"])
        command.execute
      end
    end
  end

end
