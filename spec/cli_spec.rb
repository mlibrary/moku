# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/cli"
require "fauxpaas/command"

module Fauxpaas
  class TestInvoker
    attr_accessor :commands
    def initialize
      @commands = []
    end

    def add_command(command)
      commands << command
    end
  end

  RSpec.describe CLI do
    let(:cli) { described_class }
    let(:invoker) { TestInvoker.new }
    let(:instance_name) { "myapp-mystage" }
    before(:each) do
      Fauxpaas.config.tap do |c|
        c.register(:invoker) { invoker }
      end
    end

    RSpec.shared_examples "a cli command" do |command_klass|
      it "adds a #{command_klass}" do
        cli.start([*command, instance_name, *options])
        expect(invoker.commands).to contain_exactly(an_instance_of(command_klass))
      end
      it "the command is valid" do
        cli.start([*command, instance_name, *options])
        # We cheat a bit here by knowing what validity means
        # but it gives much more useful test failure output
        expect(invoker.commands.first.missing).to be_empty
      end
    end

    describe "deploy" do
      let(:command) { ["deploy"] }
      context "with commitish" do
        let(:options) { ["some_committish"] }
        it_behaves_like "a cli command", DeployCommand
      end
      context "without commitish" do
        let(:options) { [] }
        it_behaves_like "a cli command", DeployCommand
      end
    end

    describe "default_branch" do
      let(:command) { ["default_branch"] }
      context "when reading" do
        let(:options) { [] }
        it_behaves_like "a cli command", ReadDefaultBranchCommand
      end
      context "when setting" do
        let(:options) { ["new_branch"] }
        it_behaves_like "a cli command", SetDefaultBranchCommand
      end
    end

    describe "rollback" do
      let(:command) { ["rollback"] }
      context "with commitish" do
        let(:options) { ["some_committish"] }
        it_behaves_like "a cli command", RollbackCommand
      end
      context "without commitish" do
        let(:options) { [] }
        it_behaves_like "a cli command", RollbackCommand
      end
    end

    describe "caches" do
      let(:command) { ["caches"] }
      let(:options) { [] }
      it_behaves_like "a cli command", CachesCommand
    end

    describe "releases" do
      let(:command) { ["releases"] }
      let(:options) { [] }
      it_behaves_like "a cli command", ReleasesCommand
    end

    describe "restart" do
      let(:command) { ["restart"] }
      let(:options) { [] }
      it_behaves_like "a cli command", RestartCommand
    end

    describe "syslog" do
      describe "view" do
        let(:command) { ["syslog", "view"] }
        let(:options) { [] }
        it_behaves_like "a cli command", SyslogViewCommand
      end

      describe "follow" do
        let(:command) { ["syslog", "follow"] }
        let(:options) { [] }
        it_behaves_like "a cli command", SyslogFollowCommand
      end

      describe "grep" do
        let(:command) { ["syslog", "grep"] }
        let(:options) { ["some_pattern"] }
        it_behaves_like "a cli command", SyslogGrepCommand
      end
    end
  end
end
