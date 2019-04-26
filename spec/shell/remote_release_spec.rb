# frozen_string_literal: true

require_relative "../spec_helper"
require "moku/shell/remote_release"
require "moku/sites"

module Moku

  RSpec.describe Shell::RemoteRelease do
    let(:remote_runner) { double(:remote_runner, run: double(:status, success?: true)) }
    let(:scope) { double(:scope) }
    let(:command) { "somecommand" }
    let(:user) { "someuser" }
    let(:deploy_path) { Pathname.new("/deploy/dir/releases/12345") }
    let(:env) { { rack_env: "staging", "foo" => "bar" } }
    let(:sites) do
      Sites.for(
        "user" => user,
        "site1" => ["host1", "host2"],
        "site2" => ["host3", "host4"]
      )
    end

    let(:shell) do
      described_class.new(
        sites: sites,
        deploy_path: deploy_path,
        env: env,
        remote_runner: remote_runner
      )
    end

    describe "#run" do
      before(:each) do
        allow(scope).to receive(:apply).with(sites).and_return(sites.hosts)
      end

      it "runs the commands on the hosts defined by the scope" do
        scope.apply(sites).each do |host|
          expect(remote_runner).to receive(:run)
            .with(
              user: user,
              host: host.hostname,
              command: /RACK_ENV=staging FOO=bar #{command}/
            )
        end
        shell.run(scope, command)
      end
    end
  end

end
