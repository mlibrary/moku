# frozen_string_literal: true

require "fauxpaas/cli/syslog"
require_relative "../support/mock_instance.rb"

module Fauxpaas
  RSpec.describe CLI::Syslog do
    subject(:cli) { described_class }
    let(:instance_name) { "something" }
    include_context "a mock instance"

    let(:mock_cap) { instance_double(Cap) }

    before(:each) do
      allow(mock_instance).to receive(:interrogator)
        .and_return(mock_cap)
    end

    shared_examples_for "a syslog subcommand" do |command|
      before(:each) { allow(mock_cap).to receive(:"syslog_#{command}") }

      it "runs using a KernelSystem" do
        cli.start([command, instance_name])
        expect(Fauxpaas.system_runner).to be_a_kind_of(KernelSystem)
      end

      it "calls syslog_#{command}" do
        expect(mock_cap).to receive(:"syslog_#{command}")
        cli.start([command, instance_name])
      end
    end

    describe "#view" do
      it_behaves_like "a syslog subcommand", "view"
    end

    describe "#follow" do
      it_behaves_like "a syslog subcommand", "follow"
    end

    describe "#grep" do
      it "calls syslog_grep with the given argument" do
        expect(mock_cap).to receive(:syslog_grep).with("pattern")
        cli.start(["grep", instance_name, "pattern"])
      end

      it_behaves_like "a syslog subcommand", "grep"
    end
  end
end
