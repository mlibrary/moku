# frozen_string_literal: true

require "fauxpaas/cli/main"
require "fauxpaas/components/system_runner"
require "fauxpaas/archive_reference"
require_relative "../support/mock_instance.rb"

module Fauxpaas
  RSpec.describe CLI::Main do
    after(:each) { Fauxpaas.system_runner = nil }

    subject(:cli) { described_class }
    let(:instance_name) { "something" }

    let(:mock_status) { double(:status, success?: true) }

    include_context "a mock instance"

    shared_examples_for "a Fauxpaas thor command" do |command|
      it "does not set verbose output by default" do
        cli.start([command, instance_name])
        expect(Fauxpaas.system_runner).not_to be_a_kind_of(VerboseRunner)
      end

      it "can set verbose output" do
        cli.start([command, instance_name, "--verbose"])
        expect(Fauxpaas.system_runner).to be_a_kind_of(VerboseRunner)
      end

      it "requires an instance" do
        expect { cli.start([command]) }
          .to output(/no arguments/).to_stderr
      end
    end

    describe "#deploy" do
      let(:mock_release) do
        instance_double(Release,
          deploy: mock_status)
      end
      let(:mock_cap) { instance_double(Cap, restart: mock_status) }

      before(:each) do
        allow(mock_instance).to receive(:release).and_return(mock_release)
        allow(mock_instance).to receive(:signature)
        allow(mock_instance).to receive(:log_release)
        allow(mock_instance).to receive(:interrogator).and_return(mock_cap)
      end

      it_behaves_like "a Fauxpaas thor command", "deploy"

      it "deploys an instance" do
        expect(mock_release).to receive(:deploy)
        cli.start(["deploy", instance_name])
      end

      it "logs the release" do
        expect(mock_instance).to receive(:log_release)
        cli.start(["deploy", instance_name])
      end

      it "saves the instance" do
        expect(mock_instance_repo).to receive(:save).with(mock_instance)
        cli.start(["deploy", instance_name])
      end

      it "reports success" do
        expect { cli.start(["deploy", instance_name]) }
          .to output(/deploy successful/).to_stdout
      end

      it "restarts the application" do
        expect(mock_cap).to receive(:restart)
        cli.start(["deploy", instance_name])
      end

      context "when it fails to deploy" do
        let(:mock_status) { double(:status, success?: false) }

        it "doesn't restart the application" do
          expect(mock_cap).not_to receive(:restart)
          cli.start(["deploy", instance_name])
        end
      end
    end

    describe "#default_branch" do
      it_behaves_like "a Fauxpaas thor command", "default-branch"

      before(:each) do
        allow(mock_instance).to receive(:default_branch)
        allow(mock_instance).to receive(:default_branch=)
      end

      let(:branch) { "newbranch" }

      it "sets the default branch" do
        expect(mock_instance).to receive(:"default_branch=").with(branch)
        cli.start(["default-branch", instance_name, branch])
      end

      it "saves the instance" do
        expect(mock_instance_repo).to receive(:save).with(mock_instance)
        cli.start(["default-branch", instance_name, branch])
      end

      it "reports the change" do
        expect { cli.start(["default-branch", instance_name, branch]) }
          .to output(/Changed default branch from .* to #{branch}/).to_stdout
      end
    end

    describe "#rollback" do
      it_behaves_like "a Fauxpaas thor command", "rollback"

      let(:mock_cap) { instance_double(Cap, rollback: mock_status) }

      let(:mock_source) do
        instance_double(ArchiveReference,
          latest: instance_double(ArchiveReference))
      end

      before(:each) do
        allow(mock_instance).to receive(:interrogator)
          .and_return(mock_cap)

        allow(mock_instance).to receive(:source)
          .and_return(mock_source)
      end

      it "rolls back" do
        expect(mock_cap).to receive(:rollback)
        cli.start(["rollback", instance_name])
      end

      it "rolls back to a specified release" do
        expect(mock_cap).to receive(:rollback).with(anything, "oldrelease")
        cli.start(["rollback", instance_name, "oldrelease"])
      end

      it "reports success" do
        expect { cli.start(["rollback", instance_name]) }
          .to output(/rollback successful/).to_stdout
      end
    end

    describe "#caches" do
      it_behaves_like "a Fauxpaas thor command", "caches"

      let(:mock_cap) { instance_double(Cap, caches: "cachelist") }

      before(:each) do
        allow(mock_instance).to receive(:interrogator)
          .and_return(mock_cap)
      end

      it "prints the caches" do
        expect { cli.start(["caches", instance_name]) }
          .to output(/cachelist/).to_stdout
      end
    end

    describe "#releases" do
      it_behaves_like "a Fauxpaas thor command", "releases"

      before(:each) do
        allow(mock_instance).to receive(:releases)
          .and_return(["one", "two", "three"])
      end

      it "prints the releases" do
        expect { cli.start(["releases", instance_name]) }
          .to output(/one\ntwo\nthree/).to_stdout
      end
    end

    describe "#restart" do
      it_behaves_like "a Fauxpaas thor command", "restart"

      let(:mock_cap) { instance_double(Cap, restart: mock_status) }

      before(:each) do
        allow(mock_instance).to receive(:interrogator)
          .and_return(mock_cap)
      end

      it "restarts the application" do
        expect(mock_cap).to receive(:restart)
        cli.start(["restart", instance_name])
      end

      it "reports success" do
        expect { cli.start(["restart", instance_name]) }
          .to output(/restart successful/).to_stdout
      end
    end

    describe "#syslog" do
      it "requires a subcommand" do
        expect { cli.start(["syslog"]) }
          .to output(/Commands:/).to_stdout
      end
    end
  end
end
