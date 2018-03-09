# frozen_string_literal: true

require_relative "../spec_helper"
require "fauxpaas/cli/main"
require "fauxpaas/archive_reference"
require "fauxpaas/release_builder"
require "ostruct"

module Fauxpaas
  RSpec.describe CLI::Main do
    shared_examples_for "a thor command" do |command|
      it "does not set verbose output by default" do
        cli.start([command, instance.name])
        expect(Fauxpaas.system_runner).not_to be_a_kind_of(VerboseRunner)
      end

      it "can set verbose output" do
        cli.start([command, instance.name, "--verbose"])
        expect(Fauxpaas.system_runner).to be_a_kind_of(VerboseRunner)
      end

      it "requires an instance" do
        expect { cli.start([command]) }
          .to output(/no arguments/).to_stderr
      end

      it "reports a nice error when the instance can't be found" do
        missing = "missing-instance"
        allow(Fauxpaas.instance_repo).to receive(:find).with(missing).and_raise(Errno::ENOENT)
        expect { cli.start([command, missing]) }
          .to output(/The requested instance \[#{missing}\] doesn't exist/).to_stderr
      end
    end

    let(:cli) { described_class }
      let(:instance) do
        double(
          :instance,
          name: "something",
          interrogator: cap,
          source: double(:source, latest: double(:latest)),
          log_release: true,
          signature: double(:signature),
          releases: ["one", "two", "three"]
        )
      end

    before(:each) do
      allow(Fauxpaas.instance_repo).to receive(:find).with(instance.name)
        .and_return(instance)
      allow(Fauxpaas.instance_repo).to receive(:save)
    end

    describe "#deploy" do
      let(:cap) { double(:cap, restart: status) }
      let(:release) { double(:release, deploy: status) }
      let(:release_builder) { double(:release_builder) }
      before(:each) do
        allow(ReleaseBuilder).to receive(:new).and_return(release_builder)
        allow(release_builder).to receive(:build)
          .with(instance.signature).and_return(release)
      end

      context "when it succeeds" do
        let(:status) { double(:status, success?: true) }

        it_behaves_like "a thor command", "deploy"

        it "deploys an instance" do
          expect(release).to receive(:deploy)
          cli.start(["deploy", instance.name])
        end

        it "logs the release" do
          expect(instance).to receive(:log_release)
          cli.start(["deploy", instance.name])
        end

        it "saves the instance" do
          expect(Fauxpaas.instance_repo).to receive(:save).with(instance)
          cli.start(["deploy", instance.name])
        end

        it "reports success" do
          expect { cli.start(["deploy", instance.name]) }
            .to output(/deploy successful/).to_stdout
        end

        it "restarts the application" do
          expect(cap).to receive(:restart)
          cli.start(["deploy", instance.name])
        end
      end

      context "when it fails to deploy" do
        let(:status) { double(:status, success?: false) }

        it "doesn't restart the application" do
          expect(cap).not_to receive(:restart)
          cli.start(["deploy", instance.name])
        end
      end
    end

    describe "#default_branch" do
      let(:instance) do
        OpenStruct.new(
          name: "something",
          interrogator: cap,
          default_branch: old_branch
        )
      end
      let(:cap) { double(:cap, caches: "cachelist") }
      let(:old_branch) { "old_branch" }
      let(:new_branch) { "new_branch" }

      it_behaves_like "a thor command", "default-branch"

      it "sets the default branch" do
        expect { cli.start(["default-branch", instance.name, new_branch]) }
          .to change{ instance.default_branch }
          .from(old_branch)
          .to(new_branch)
      end

      it "saves the instance" do
        new_instance = instance.dup
        new_instance.default_branch = new_branch
        expect(Fauxpaas.instance_repo).to receive(:save).with(new_instance)
        cli.start(["default-branch", instance.name, new_branch])
      end

      it "reports the change" do
        expect { cli.start(["default-branch", instance.name, new_branch]) }
          .to output(/Changed default branch from .* to #{new_branch}/).to_stdout
      end
    end

    describe "#rollback" do
      let(:cap) { double(:cap, rollback: double(:status, success?: true)) }

      it_behaves_like "a thor command", "rollback"

      it "rolls back" do
        expect(cap).to receive(:rollback)
        cli.start(["rollback", instance.name])
      end

      it "rolls back to a specified release" do
        expect(cap).to receive(:rollback).with(anything, "oldrelease")
        cli.start(["rollback", instance.name, "oldrelease"])
      end

      it "reports success" do
        expect { cli.start(["rollback", instance.name]) }
          .to output(/rollback successful/).to_stdout
      end
    end

    describe "#caches" do
      let(:cap) { double(:cap, caches: "cachelist") }

      it_behaves_like "a thor command", "caches"

      it "prints the caches" do
        expect { cli.start(["caches", instance.name]) }
          .to output(/cachelist/).to_stdout
      end
    end

    describe "#releases" do
      let(:cap) { double(:unused_cap) }

      it_behaves_like "a thor command", "releases"

      it "prints the releases" do
        expect { cli.start(["releases", instance.name]) }
          .to output(/one\ntwo\nthree/).to_stdout
      end
    end


    describe "#restart" do
      let(:cap) { double(:cap, restart: double(:status, success?: true)) }

      it_behaves_like "a thor command", "restart"

      it "restarts the application" do
        expect(cap).to receive(:restart)
        cli.start(["restart", instance.name])
      end

      it "reports success" do
        expect { cli.start(["restart", instance.name]) }
          .to output(/restart successful/).to_stdout
      end
    end

  end
end
