# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/syslog_follow"

module Fauxpaas

  RSpec.describe Commands::SyslogFollow do
    include_context "a command spec"
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
      )
    end
    it_behaves_like "a command"

    it "action is :syslog_follow" do
      expect(command.action).to eql(:syslog_follow)
    end

    describe "#execute" do
      let(:instance) do
        double(
          :instance,
          interrogator: double(
            :interrogator,
            syslog_follow: nil
          )
        )
      end
      it "tells cap to syslog_follow" do
        expect(instance.interrogator).to receive(:syslog_follow)
        command.execute
      end
    end
  end

end
