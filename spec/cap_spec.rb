# frozen_string_literal: true

require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require "fauxpaas/cap"

module Fauxpaas
  RSpec.describe Cap do
    let(:capfile_path) { "/capfiles/rails.capfile" }
    let(:stage) { "myapp-staging" }
    let(:backend_runner) { double(:backend_runner) }
    let(:options) do
      {
        appname:          stage,
        deploy_dir:       "/some/dir",
        deployer_env:     capfile_path,
        rails_env:        "prod",
        assets_prefix:    "assets",
        systemd_services: ["foo.service", "bar.service"]
      }
    end
    let(:cap) { described_class.new(options, stage, backend_runner) }

    RSpec.shared_examples "a cap task" do |task|
      it "passes the capfile_path" do
        expect(backend_runner).to receive(:run)
          .with(capfile_path, anything, anything, anything)
        subject
      end
      it "uses name as the stage" do
        expect(backend_runner).to receive(:run)
          .with(anything, stage, anything, anything)
        subject
      end
      it "sets :application" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            application: options[:appname]
        ))
        subject
      end
      it "sets :deploy_dir" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            deploy_dir: options[:deploy_dir]
        ))
        subject
      end
      it "sets :rails_env" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            rails_env: options[:rails_env]
        ))
        subject
      end
      it "sets :assets_prefix" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            assets_prefix: options[:assets_prefix]
        ))
        subject
      end
      it "runs the '#{task}' task" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, task, anything)
        subject
      end
    end

    describe "#deploy" do
      let(:source_path) { Pathname.new("some/path/source") }
      let(:shared_path) { Pathname.new("some/path/shared") }
      let(:unshared_path) { Pathname.new("some/path/unshared") }
      subject { cap.deploy(source_path, shared_path, unshared_path) }

      it_behaves_like "a cap task", "deploy"

      it "sets :shared_path" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            shared_config_path: shared_path.to_s
        ))
        subject
      end

      it "sets :unshared_path" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            unshared_config_path: unshared_path.to_s
        ))
        subject
      end
    end

    describe "#caches" do
      let(:stderr) do
        "#{Fauxpaas.settings.split_token}\n" \
          "onecache\ntwocache\nthreecache\n" \
          "#{Fauxpaas.settings.split_token}\n"
      end

      before(:each) do
        allow(backend_runner).to receive(:run)
          .and_return(["", stderr, :status])
      end

      subject { cap.caches }

      it_behaves_like "a cap task", "caches:list"

      it "returns a list of caches" do
        allow(backend_runner).to receive(:run)
          .and_return(["", stderr, ""])
        expect(subject).to eql(["onecache", "twocache", "threecache"])
      end
    end

    describe "#rollback", skip: true do
      let(:source) { double(:source, url: "someurl", commitish: "someref") }
      let(:cache) { "20160614133327" }

      subject { cap.rollback(source, cache) }

      it_behaves_like "a cap task", "deploy:rollback"

      it "sets :rollback_release" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(rollback_release: cache))
        subject
      end
    end

    describe "#restart" do
      subject { cap.restart }

      it_behaves_like "a cap task", "systemd:restart"

      it "sets :systemd_services" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything,
            a_hash_including(systemd_services: "foo.service:bar.service"))
        subject
      end
    end

    describe "#exec" do
      let(:role) { "app" }
      let(:bin) { "bundle" }
      let(:args) { "exec rake db:dostuff" }
      let(:env) {{ foo: "bar", boom: "parrot" }}

      subject { cap.exec(role: role, bin: bin, args: args, env: env) }

      it_behaves_like "a cap task", "commands:run_one"

      it "runs the arbitrary command" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything, a_hash_including(
            faux_role: role,
            faux_bin: bin,
            faux_args: args,
            faux_vars: "foo=bar:boom=parrot"
          ))
        subject
      end
    end

    describe "#syslog_view" do
      subject { cap.syslog_view }

      it_behaves_like "a cap task", "syslog:view"
    end

    describe "#syslog_follow" do
      subject { cap.syslog_follow }

      it_behaves_like "a cap task", "syslog:follow"
    end

    describe "#syslog_grep" do
      subject { cap.syslog_grep("pattern") }

      it_behaves_like "a cap task", "syslog:grep"

      it "sets :grep_pattern" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything,
            a_hash_including(grep_pattern: "pattern"))
        subject
      end
    end

    context "when options does not include systemd_services" do
      let(:options) do
        {
          appname:       stage,
          deploy_dir:    "/some/dir",
          deployer_env:  capfile_path,
          rails_env:     "prod",
          assets_prefix: "assets"
        }
      end

      subject { cap.restart }

      it_behaves_like "a cap task", "systemd:restart"

      it "sets :systemd_services to the empty string" do
        expect(backend_runner).to receive(:run)
          .with(anything, anything, anything,
            a_hash_including(systemd_services: ""))
        subject
      end
    end
  end
end
