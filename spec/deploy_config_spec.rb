# frozen_string_literal: true

require_relative "./spec_helper"
require "active_support/core_ext/hash/keys"
require "fauxpaas/deploy_config"

module Fauxpaas
  RSpec.describe DeployConfig do
    let(:options) do
      {
        appname:          "myapp-mystage",
        deployer_env:     "foo",
        deploy_dir:       Pathname.new("bar/baz"),
        rails_env:        "staging",
        assets_prefix:    "notassets",
        systemd_services: ["foo.service", "bar.service"]
      }
    end
    let(:deploy_config) { described_class.new(options) }

    describe "#runner" do
      it "returns a runner"
    end

    describe "#to_hash" do
      it "returns a hash with string keys" do
        expect(deploy_config.to_hash).to eql(options.stringify_keys)
      end
    end

    describe "serialization" do
      it "can serialize and deserialize itself (hashify)" do
        expect(described_class.from_hash(deploy_config.to_hash)).to eql(deploy_config)
      end
    end
  end
end
