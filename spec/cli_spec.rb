# frozen_string_literal: true

require "fauxpaas/cli/main"

require_relative "./support/mock_instance.rb"

module Fauxpaas
  RSpec.describe CLI::Main do
    include_context "with mocked instance repo and instance"

    after(:each) { Fauxpaas.system_runner = nil }

    let(:instance_name) { "something" }

    shared_examples_for "a thor subcommand" do |command|
      it "does not set verbose output by default" do
        described_class.start([command, instance_name])
        expect(Fauxpaas.system_runner).not_to be_a_kind_of(VerboseSystemRunner)
      end

      it "can set verbose output" do
        described_class.start([command, instance_name, "--verbose"])
        expect(Fauxpaas.system_runner).to be_a_kind_of(VerboseSystemRunner)
      end

      it "requires an instance" do
        expect { described_class.start([command]) }
          .to output(/no arguments/).to_stderr
      end
    end

    describe "#deploy" do
      it_behaves_like "a thor subcommand", "deploy"

      subject { described_class.start(["deploy", instance_name]) }

      it "deploys an instance" do
        expect(mock_release).to receive(:deploy)
        subject
      end

      it "logs the release" do
        expect(mock_instance).to receive(:log_release)
        subject
      end

      it "saves the instance" do
        expect(mock_instance_repo).to receive(:save).with(mock_instance)
        subject
      end

      it "reports success" do
        expect { subject }
          .to output(/deploy successful/).to_stdout
      end
    end

    describe "#default_branch" do
      it_behaves_like "a thor subcommand", "default-branch"

      let(:branch) { "newbranch" }

      subject { described_class.start(["default-branch", instance_name, branch]) }

      it "sets the default branch" do
        expect(mock_instance).to receive(:"default_branch=").with(branch)
        subject
      end

      it "saves the instance" do
        expect(mock_instance_repo).to receive(:save).with(mock_instance)
        subject
      end

      it "reports the change" do
        expect { subject }
          .to output(/Changed default branch from .* to #{branch}/).to_stdout
      end
    end

    describe "#rollback" do
      it_behaves_like "a thor subcommand", "rollback"

      subject { described_class.start(["rollback", instance_name]) }

      it "rolls back" do
        expect(mock_cap).to receive(:rollback)
        subject
      end

      it "rolls back to a specified release" do
        expect(mock_cap).to receive(:rollback).with(anything, "oldrelease")
        described_class.start(["rollback", instance_name, "oldrelease"])
      end

      it "reports success" do
        expect { subject }
          .to output(/rollback successful/).to_stdout
      end
    end

    describe "#caches" do
      it_behaves_like "a thor subcommand", "caches"

      it "prints the caches" do
        expect { described_class.start(["caches", instance_name]) }
          .to output(/cachelist/).to_stdout
      end
    end

    describe "#releases" do
      it_behaves_like "a thor subcommand", "releases"

      it "prints the releases" do
        expect { described_class.start(["releases", instance_name]) }
          .to output(/one\ntwo\nthree/).to_stdout
      end
    end

    describe "#restart" do
      it_behaves_like "a thor subcommand", "restart"

      subject { described_class.start(["restart", instance_name]) }

      it "restarts the application" do
        expect(mock_cap).to receive(:restart)
        subject
      end

      it "reports success" do
        expect { subject }
          .to output(/restart successful/).to_stdout
      end
    end
  end
end
