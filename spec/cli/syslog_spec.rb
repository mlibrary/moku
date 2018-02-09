# frozen_string_literal: true

require_relative "../spec_helper"
require "fauxpaas/cli/syslog"
require "fauxpaas/kernel_system"

module Fauxpaas
	RSpec.describe CLI::Syslog do
		RSpec.shared_examples_for "a syslog subcommand" do |command|
			it "runs using a KernelSystem" do
				cli.start([command, "myapp-staging"])
				expect(Fauxpaas.system_runner).to be_a_kind_of(KernelSystem)
			end
			it "requires an instance" do
				expect { cli.start([command]) }
					.to output(/no arguments/).to_stderr
			end
		end

		let(:cli) { described_class }
		let(:instance) { double(:instance, name: "myapp-staging", interrogator: cap) }
		let(:cap) { double(:cap) }
		before(:each) do
			allow(Fauxpaas.instance_repo).to receive(:find).with(instance.name)
				.and_return(instance)
		end
		describe "#view" do
      before(:each) do
        allow(cap).to receive(:syslog_view)
      end
      it_behaves_like "a syslog subcommand", "view"
			it "runs syslog:view" do
				expect(cap).to receive(:syslog_view).with(no_args)
				cli.start(["view", instance.name])
			end
		end
		describe "#follow" do
      before(:each) do
        allow(cap).to receive(:syslog_follow)
      end
      it_behaves_like "a syslog subcommand", "follow"
			it "runs syslog:follow" do
				expect(cap).to receive(:syslog_follow).with(no_args)
				cli.start(["follow", instance.name])
			end
		end
		describe "#grep" do
      before(:each) do
        allow(cap).to receive(:syslog_grep)
      end
      it_behaves_like "a syslog subcommand", "grep"
			let(:pattern) { "some\\n\//\/\\/pattern" }
			it "runs syslog:grep" do
				expect(cap).to receive(:syslog_grep).with(pattern)
				cli.start(["grep", instance.name, pattern])
			end
		end
	end
end
