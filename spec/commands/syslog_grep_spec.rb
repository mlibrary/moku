# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/syslog_grep"

module Fauxpaas
  RSpec.describe Commands::SyslogGrep do
    include_context "a command spec"
    let(:pattern) { "some\\n\//\/\\/pattern" }
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        pattern: pattern
      )
    end
    it_behaves_like "a command"

    it "action is :syslog_grep" do
      expect(command.action).to eql(:syslog_grep)
    end

    describe "#execute" do
      let(:instance) do
        double(
          :instance,
          interrogator: double(
            :interrogator,
            syslog_grep: nil
          )
        )
      end
      it "tells cap to syslog_grep" do
        expect(instance.interrogator).to receive(:syslog_grep)
          .with(pattern)
        command.execute
      end
    end
  end
end
