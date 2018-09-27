# frozen_string_literal: true

require "fauxpaas/deploy_config"
require "fauxpaas/sites"
require "core_extensions/hash/keys"
require "fileutils"
require "pathname"
require "yaml"

require "pp"
require "fakefs/spec_helpers"

require "fauxpaas/config"

module Fauxpaas
  RSpec.describe DeployConfig do

    before(:each) do
      Fauxpaas.config.register(:deploy_config_filename) { "deploy.yml" }
    end

    let(:deploy_dir) { Pathname.new("/deploy/dir") }
    let(:env) {{ rack_env: "staging" }}
    let(:systemd_services) { ["foo.service", "bar.service"] }
    let(:sites) { { "site1" => ["host1"], "site2" => ["host2"] } }
    let(:hash) do
      {
        deploy_dir: deploy_dir.to_s,
        env: env,
        systemd_services: systemd_services,
        sites: sites
      }
    end
    let(:deploy_config) do
      described_class.new(
        deploy_dir: deploy_dir,
        env: env,
        systemd_services: systemd_services,
        sites: Sites.new(sites)
      )
    end

    describe "::from_hash" do
      it "returns the object" do
        expect(described_class.from_hash(hash)).to eql(deploy_config)
      end
    end

    describe "::from_dir" do
      include FakeFS::SpecHelpers
      let(:path) { Pathname.new("/some/path/deploy.yml") }
      let(:dir) { double(:dir, path: path.dirname) }
      before(:each) do
        FileUtils.mkdir_p path.dirname
        File.write(path.to_s, YAML.dump(hash))
      end
      it "returns the object" do
        expect(described_class.from_dir(dir)).to eql(deploy_config)
      end
    end

    describe "::from_ref" do
      include FakeFS::SpecHelpers
      let(:path) { Pathname.new("/some/path/deploy.yml") }
      let(:dir) { double(:dir, path: path.dirname) }
      let(:ref) { double(:ref) }
      let(:ref_repo) { double(:ref_repo) }
      before(:each) do
        FileUtils.mkdir_p path.dirname
        File.write(path.to_s, YAML.dump(hash))
        allow(ref_repo).to receive(:resolve).with(ref).and_return(dir)
      end
      it "returns the object" do
        expect(described_class.from_ref(ref, ref_repo)).to eql(deploy_config)
      end
    end

    describe "#shell_env" do
      let(:env) {{ rack_env: "staging", "foo" => "bar" }}
      it "renders the env shell readable" do
        expect(deploy_config.shell_env).to eql("RACK_ENV=staging FOO=bar")
      end

    end


  end
end
