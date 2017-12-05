require_relative "./spec_helper"
require_relative "./support/spoofed_git_runner"
require "fauxpaas/deploy_archive"
require "fauxpaas/deploy_config"
require "pathname"

module Fauxpaas
  RSpec.describe DeployArchive do
    let(:deploy_config) do
      DeployConfig.new(
        appname: "myapp-mystage",
        deployer_env: "foo.capfile",
        assets_prefix: "assets",
        rails_env: "production",
        deploy_dir: "/path/to/deploy/dir"
      )
    end

    let(:runner) { SpoofedGitRunner.new }
    let(:url) { "https://example.com/fake.git" }
    let(:tmpdir) { Pathname.new("/tmp") }
    let(:root_dir) { Pathname.new("some/dir") }
    let(:fs) { double(:fs) }

    let(:deploy_archive) { described_class.new(url, runner.branch, root_dir, fs: fs) }

    before(:each) do
      Fauxpaas.git_runner = runner
      allow(runner).to receive(:safe_checkout).with(url, runner.branch)
        .and_yield(tmpdir)
      allow(fs).to receive(:read).with(tmpdir/root_dir/"deploy.yml")
        .and_return(YAML.dump(deploy_config.to_hash))
    end

    describe "#deploy_config" do
      it "builds a deploy_config object from the reference" do
        expect(deploy_archive.deploy_config).to eql(deploy_config)
      end
    end

  end
end
