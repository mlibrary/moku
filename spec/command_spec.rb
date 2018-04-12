# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/command"

module Fauxpaas
  class TestRunner
    attr_accessor :commands
    def initialize
      @commands = []
    end

    def run(string)
      commands << string
    end
  end

  RSpec.describe "commands" do
    RSpec.shared_examples "a command" do
      let(:sys_runner) { TestRunner.new }
      before(:each) do
        Fauxpaas.config.tap do |c|
          c.register(:system_runner) { sys_runner }
        end
      end

      describe "#default_keys" do
        it "returns the set of default keys" do
          expect(command.default_keys).to contain_exactly(:server, :instance_name)
        end
      end

      describe "#extra_keys" do
        it "is an array" do
          expect(command.extra_keys).to be_a_kind_of(Array)
        end
      end

      describe "#keys" do
        it "is the union of #default_keys and #extra_keys" do
          union = (command.default_keys + command.extra_keys).uniq
          expect(command.keys).to contain_exactly(*union)
        end
      end

      describe "#missing" do
        it "is keys - options.keys" do
          required_keys = command.keys
          provided_keys = options.keys.reject {|k| options[k].nil? }
          expect(command.missing).to contain_exactly(*(required_keys - provided_keys))
        end
      end

      describe "#valid?" do
        it "is valid if there are no missing keys" do
          expect(command.valid?).to eql(command.missing.empty?)
        end
      end

      describe "#execute" do
        it "runs the ssh command" do
          command.execute
          expect(sys_runner.commands.size).to eql(1)
          expect(sys_runner.commands.first.strip).to eql(ssh_command)
        end
      end
    end

    let(:server) { "localhost" }

    describe DeployCommand do
      let(:command) { described_class.new(options) }
      context "with a reference" do
        let(:options) { { server: server, instance_name: "myapp-mystage", reference: "beta2" } }
        let(:ssh_command) { "ssh #{Fauxpaas.server} deploy myapp-mystage beta2" }
        it_behaves_like "a command"
      end
      context "without a reference" do
        let(:options) { { server: server, instance_name: "myapp-mystage", reference: nil } }
        let(:ssh_command) { "ssh #{Fauxpaas.server} deploy myapp-mystage" }
        it_behaves_like "a command"
      end
    end

    describe SetDefaultBranchCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { server: server, instance_name: "myapp-mystage", new_branch: "new_branch" } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} default_branch myapp-mystage new_branch" }
      it_behaves_like "a command"
    end

    describe ReadDefaultBranchCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { server: server, instance_name: "myapp-mystage" } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} default_branch myapp-mystage" }
      it_behaves_like "a command"
    end

    describe RollbackCommand do
      let(:command) { described_class.new(options) }
      context "with a cache" do
        let(:options) { { server: server, instance_name: "myapp-mystage", cache: "somecache" } }
        let(:ssh_command) { "ssh #{Fauxpaas.server} rollback myapp-mystage somecache" }
        it_behaves_like "a command"
      end
      context "without a cache" do
        let(:options) { { server: server, instance_name: "myapp-mystage", cache: nil } }
        let(:ssh_command) { "ssh #{Fauxpaas.server} rollback myapp-mystage" }
        it_behaves_like "a command"
      end
    end

    describe CachesCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { server: server, instance_name: "myapp-mystage" } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} caches myapp-mystage" }
      it_behaves_like "a command"
    end

    describe ReleasesCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { server: server, instance_name: "myapp-mystage" } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} releases myapp-mystage" }
      it_behaves_like "a command"
    end

    describe RestartCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { server: server, instance_name: "myapp-mystage" } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} restart myapp-mystage" }
      it_behaves_like "a command"
    end

    describe SyslogViewCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { server: server, instance_name: "myapp-mystage" } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} syslog view myapp-mystage" }
      it_behaves_like "a command"
    end

    describe SyslogFollowCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { server: server, instance_name: "myapp-mystage" } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} syslog follow myapp-mystage" }
      it_behaves_like "a command"
    end

    describe SyslogGrepCommand do
      let(:command) { described_class.new(options) }
      let(:pattern) { "some\\n\//\/\\/pattern" }
      let(:options) { { server: server, instance_name: "myapp-mystage", pattern: pattern } }
      let(:ssh_command) { "ssh #{Fauxpaas.server} syslog grep myapp-mystage #{pattern}" }
      it_behaves_like "a command"
    end
  end
end
