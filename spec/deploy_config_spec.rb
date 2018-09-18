# frozen_string_literal: true

require_relative "./spec_helper"
require "fakefs/spec_helpers"
require "core_extensions/hash/keys"
require "fauxpaas/deploy_config"
require "pathname"
require "fileutils"

module Fauxpaas
  RSpec.describe DeployConfig do
    include FakeFS::SpecHelpers
    let(:options) do
      {
        appname:          "myapp-mystage",
        deployer_env:     "foo",
        deploy_dir:       Pathname.new("bar/baz"),
        rails_env:        "staging",
        systemd_services: ["foo.service", "bar.service"]
      }
    end
    let(:hash) { options.stringify_keys }
    let(:deploy_config) { described_class.new(options) }

    describe "#runner" do
      it "returns a runner"
    end

    describe "#from_hash" do
      it "returns the instance" do
        expect(described_class.from_hash(hash)).to eql(deploy_config)
      end
    end

    describe "#from_dir" do
      let(:path) { Pathname.new("/some/path") }
      let(:config_path) { path/"deploy.yml" }
      let(:dir) { double(:dir, path: path) }
      before(:each) do
        FileUtils.mkdir_p path
        File.write(config_path.to_s, YAML.dump(hash))
      end
      it "returns the instance" do
        expect(described_class.from_dir(dir)).to eql(deploy_config)
      end
    end

    describe "#from_ref" do
      let(:path) { Pathname.new("/some/path") }
      let(:config_path) { path/"deploy.yml" }
      let(:dir) { double(:dir, path: path) }
      let(:ref) { double(:ref) }
      let(:ref_repo) { double(:ref_repo) }
      before(:each) do
        FileUtils.mkdir_p path
        File.write(config_path.to_s, YAML.dump(hash))
        allow(ref_repo).to receive(:resolve).with(ref).and_return(dir)
      end
      it "returns the instance" do
        expect(described_class.from_ref(ref, ref_repo)).to eql(deploy_config)
      end
    end

    describe "#to_hash" do
      it "returns a hash with string keys" do
        expect(deploy_config.to_hash).to eql(hash)
      end
    end

    describe "serialization" do
      it "can serialize and deserialize itself (hashify)" do
        expect(described_class.from_hash(deploy_config.to_hash)).to eql(deploy_config)
      end
    end
  end
end
