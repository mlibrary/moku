# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/command"

module Fauxpaas
  RSpec.describe "commands" do
    RSpec.shared_examples "a command" do
      describe "#default_keys" do
        it "returns the set of default keys" do
          expect(command.default_keys).to contain_exactly(:instance_name)
        end
      end

      describe "#action" do
        it "returns a symbol" do
          expect(command.action).to be_an_instance_of Symbol
        end
      end

      describe "#authorized?" do
        it "calls out to the auth system" do
          expect(auth).to receive(:authorized?).with(
            user: options[:user],
            entity: instance,
            action: command.action
          )
          command.authorized?
        end
        it "delegates to the auth system" do
          expect(command.authorized?).to eql(auth.authorized?)
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
          expect(command.missing).to contain_exactly(*(command.keys - options.keys))
        end
      end

      describe "#valid?" do
        it "is valid if there are no missing keys" do
          expect(command.valid?).to eql(command.missing.empty?)
        end
      end
    end

    let(:instance_repo) do
      double(
        :instance_repo,
        find: instance,
        save_instance: nil,
        save_releases: nil
      )
    end
    let(:auth) { double(:auth, authorized?: true) }
    let(:instance) { double(:instance) }
    before(:each) do
      Fauxpaas.config.tap do |c|
        c.register(:auth) { auth }
        c.register(:instance_repo) { instance_repo }
      end
    end

    describe Command do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage" } }
      it_behaves_like "a command"
    end

    describe DeployCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage", reference: nil } }
      it_behaves_like "a command"

      it "action is :deploy" do
        expect(command.action).to eql(:deploy)
      end

      describe "#execute" do
        let(:release) { double(:release, deploy: status) }
        let(:release_builder) { double(:release_builder) }
        let(:instance) do
          double(
            :instance,
            name: "something",
            interrogator: double(:interrogator,
              deploy: OpenStruct.new(success?: true),
              restart: OpenStruct.new(success?: true)),
            source: double(:source, latest: double(:latest)),
            log_release: true,
            signature: double(:signature),
            releases: ["one", "two", "three"]
          )
        end
        before(:each) do
          allow(ReleaseBuilder).to receive(:new).and_return(release_builder)
          allow(release_builder).to receive(:build)
            .with(instance.signature).and_return(release)
        end
        context "when it succeeds" do
          let(:status) { double(:status, success?: true) }
          it "tells cap to deploy" do
            expect(release).to receive(:deploy)
            command.execute
          end
          it "tells cap to restart" do
            expect(instance.interrogator).to receive(:restart)
            command.execute
          end
          it "saves the release" do
            expect(instance).to receive(:log_release)
            expect(instance_repo).to receive(:save_releases).with(instance)
            command.execute
          end
          it "reports success" do
            command.execute
            Fauxpaas.log_file.rewind
            expect(Fauxpaas.log_file.read).to match(/deploy successful/)
          end
        end
        context "when it fails to deploy" do
          let(:status) { double(:status, success?: false) }
          it "doesn't restart the application" do
            expect(instance.interrogator).to_not receive(:restart)
            command.execute
          end
        end
      end
    end

    describe SetDefaultBranchCommand do
      let(:command) { described_class.new(options) }
      let(:options) do
        { user: "someone", instance_name: "myapp-mystage", new_branch: "new_branch" }
      end
      it_behaves_like "a command"

      it "action is :set_default_branch" do
        expect(command.action).to eql(:set_default_branch)
      end

      describe "#execute" do
        let(:instance) { OpenStruct.new(default_branch: "old_branch") }
        it "saves the changed branch" do
          expect(instance_repo).to receive(:save_instance)
            .with(OpenStruct.new(default_branch: "new_branch"))
          command.execute
        end
      end
    end

    describe ReadDefaultBranchCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage" } }
      it_behaves_like "a command"

      it "action is :read_default_branch" do
        expect(command.action).to eql(:read_default_branch)
      end

      describe "#execute" do
        let(:instance) do
          double(:instance,
            default_branch: "master")
        end

        # TODO: convert this to print to stdout, inserted via stringio
        it "logs the default branch" do
          expect(Fauxpaas.logger).to receive(:info).with("Default branch: master")
          command.execute
        end
      end
    end

    describe RollbackCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage", cache: "foo" } }
      it_behaves_like "a command"

      it "action is :rollback" do
        expect(command.action).to eql(:rollback)
      end

      describe "#execute" do
        let(:instance) do
          double(:instance,
            interrogator: double(:interrogator,
              rollback: OpenStruct.new(success?: true)),
            source: double(:source,
              latest: "latest_source"))
        end
        it "tells cap to rollback" do
          expect(instance.interrogator).to receive(:rollback)
            .with(instance.source.latest, options[:cache])
          command.execute
        end
      end
    end

    describe CachesCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage" } }
      it_behaves_like "a command"

      it "action is :caches" do
        expect(command.action).to eql(:caches)
      end

      describe "#execute" do
        let(:instance) do
          double(:instance,
            interrogator: double(:interrogator,
              caches: ["cache1", "cache2"]))
        end

        # TODO: convert this to print to stdout, inserted via stringio
        it "logs the caches" do
          expect(Fauxpaas.logger).to receive(:info).with(["cache1", "cache2"])
          command.execute
        end
      end
    end

    describe ReleasesCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage" } }
      it_behaves_like "a command"

      it "action is :releases" do
        expect(command.action).to eql(:releases)
      end

      describe "#execute" do
        let(:instance) do
          double(:instance,
            releases: [1, 2, 3, 4])
        end

        # TODO: convert this to print to stdout, inserted via stringio
        it "logs the releases" do
          expect(Fauxpaas.logger).to receive(:info).with([1, 2, 3, 4].join("\n"))
          command.execute
        end
      end
    end

    describe RestartCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage" } }
      it_behaves_like "a command"

      it "action is :restart" do
        expect(command.action).to eql(:restart)
      end

      describe "#execute" do
        let(:instance) do
          double(:instance,
            interrogator: double(:interrogator,
              restart: OpenStruct.new(success?: true)))
        end
        it "tells cap to restart" do
          expect(instance.interrogator).to receive(:restart)
          command.execute
        end
      end
    end

    describe SyslogViewCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage" } }
      it_behaves_like "a command"

      it "action is :syslog_view" do
        expect(command.action).to eql(:syslog_view)
      end

      describe "#execute" do
        let(:instance) do
          double(
            :instance,
            interrogator: double(
              :interrogator,
              syslog_view: nil
            )
          )
        end
        it "tells cap to restart" do
          expect(instance.interrogator).to receive(:syslog_view)
          command.execute
        end
      end
    end

    describe SyslogFollowCommand do
      let(:command) { described_class.new(options) }
      let(:options) { { user: "someone", instance_name: "myapp-mystage" } }
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
        it "tells cap to restart" do
          expect(instance.interrogator).to receive(:syslog_follow)
          command.execute
        end
      end
    end

    describe SyslogGrepCommand do
      let(:command) { described_class.new(options) }
      let(:pattern) { "some\\n\//\/\\/pattern" }
      let(:options) { { user: "someone", instance_name: "myapp-mystage", pattern: pattern } }
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
        it "tells cap to restart" do
          expect(instance.interrogator).to receive(:syslog_grep)
            .with(pattern)
          command.execute
        end
      end
    end
  end
end
