# frozen_string_literal: true

require_relative "./spec_helper"
require "fakefs/spec_helpers"
require "fauxpaas/file_policy_factory_repo"
require "fauxpaas/policy_factory"

module Fauxpaas
  RSpec.describe FilePolicyFactoryRepo do
    include FakeFS::SpecHelpers

    let(:all) {{ "edit" => ["bhock"] }}
    let(:myapp_staging) {{ "deploy" => ["bhock"], "edit" => ["aelkiss"] }}
    let(:yourapp_testing) {{ "admin" => ["bhock", "aelkiss"], "edit" => [] }}
    let(:instances_root) { Pathname.new("/some/instances/root") }

    let(:policy_factory) do
      PolicyFactory.new(
        policy_type: Array,
        all: all,
        instances: {
          "myapp-staging" => myapp_staging,
          "yourapp-testing" => yourapp_testing
        }
      )
    end

    before(:each) { instances_root.mkpath }

    describe "#find" do
      it "finds the policy factory" do
        (instances_root/"myapp-staging").mkpath
        (instances_root/"yourapp-testing").mkpath
        File.write(instances_root/"permissions.yml", YAML.dump(all))
        File.write(instances_root/"myapp-staging"/"permissions.yml", YAML.dump(myapp_staging))
        File.write(instances_root/"yourapp-testing"/"permissions.yml", YAML.dump(yourapp_testing))

        factory = described_class.new(instances_root, policy_type: Array).find

        expect(factory.for("aelkiss", "myapp-staging")).to contain_exactly(:edit)
        expect(factory.for("bhock", "myapp-staging")).to contain_exactly(:deploy, :edit)
        expect(factory.for("aelkiss", "yourapp-testing")).to contain_exactly(:admin)
        expect(factory.for("bhock", "yourapp-testing")).to contain_exactly(:admin, :edit)
      end

      it "can handle uninitialized file structure" do
        factory = described_class.new(instances_root, policy_type: Array).find
        expect(factory.for("bhock", "no-app")).to eql []
      end

      it "can handle empty permissions files" do
        (instances_root/"myapp-staging").mkpath
        (instances_root/"yourapp-testing").mkpath

        File.write(instances_root/"permissions.yml", "")
        File.write(instances_root/"myapp-staging"/"permissions.yml", "")
        File.write(instances_root/"yourapp-testing"/"permissions.yml", "")

        factory = described_class.new(instances_root, policy_type: Array).find

        expect(factory.for("aelkiss", "myapp-staging")).to eql([])
        expect(factory.for("bhock", "myapp-staging")).to eql([])
        expect(factory.for("aelkiss", "yourapp-testing")).to eql([])
        expect(factory.for("bhock", "yourapp-testing")).to eql([])
      end
    end

    describe "#save" do
      it "saves the policy factory to disk" do
        described_class.new(instances_root).save(policy_factory)
        expect(YAML.load(File.read(instances_root/"permissions.yml"))).to eql(all)
        expect(YAML.load(File.read(instances_root/"myapp-staging"/"permissions.yml"))).to eql(myapp_staging)
        expect(YAML.load(File.read(instances_root/"yourapp-testing"/"permissions.yml"))).to eql(yourapp_testing)
      end
    end

  end
end

