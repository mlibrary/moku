# frozen_string_literal: true

require "fauxpaas/cli/syslog"

module Fauxpaas
  RSpec.describe CLI::Syslog do
    let(:cli) { described_class }
    let(:instance_repo) { double(:repo) }
    let(:instance) { double(:instance, name: "something", interrogator: cap) }
    let(:cap) { double(:cap) }
    before(:each) do
      Fauxpaas.instance_repo = instance_repo
      allow(instance_repo).to receive(:find).with(instance.name)
        .and_return(instance)
    end

    describe "#view" do
      it "runs syslog:view" do
        expect(cap).to receive(:syslog_view).with(no_args)
        cli.start(["view", instance.name])
      end
    end
    describe "#follow" do
      it "runs syslog:follow" do
        expect(cap).to receive(:syslog_follow).with(no_args)
        cli.start(["follow", instance.name])
      end
    end
    describe "#grep" do
      let(:pattern) { "some\\n\//\/\\/pattern" }
      it "runs syslog:grep" do
        expect(cap).to receive(:syslog_grep).with(pattern)
        cli.start(["grep", instance.name, pattern])
      end
    end
  end
end
