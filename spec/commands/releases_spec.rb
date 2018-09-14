# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/releases"

module Fauxpaas

  RSpec.describe Commands::Releases do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
      )
    end
    it_behaves_like "a command"

    it "action is :releases" do
      expect(command.action).to eql(:releases)
    end

    describe "#execute" do
      let(:instance) do
        double(:instance,
               releases: [1, 2, 3, 4])
      end
      let(:logged_releases) do
        double(
          :logged_releases,
          to_short_s: "some_string"
        )
      end

      before(:each) do
        allow(LoggedReleases).to receive(:new).with([1,2,3,4])
          .and_return(logged_releases)
      end


      # TODO: convert this to print to stdout, inserted via stringio
      it "logs the releases" do
        expect(Fauxpaas.logger).to receive(:info).with("\nsome_string")
        command.execute
      end
    end
  end

end
