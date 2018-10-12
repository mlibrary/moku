# frozen_string_literal: true

require "fauxpaas/file_permissions_repo"
require "fakefs/spec_helpers"
require "pathname"
require "yaml"

module Fauxpaas
  RSpec.describe FilePermissionsRepo do
    include FakeFS::SpecHelpers

    let(:all) { { "edit" => ["bhock"] } }
    let(:myapp_staging) { { "deploy" => ["bhock"], "edit" => ["aelkiss"] } }
    let(:yourapp_testing) { { "admin" => ["bhock", "aelkiss"], "edit" => [] } }
    let(:instances_root) { Pathname.new("/some/instances/root") }

    let(:permissions) do
      {
        all:       all,
        instances: {
          "myapp-staging"   => myapp_staging,
          "yourapp-testing" => yourapp_testing
        }
      }
    end

    before(:each) { instances_root.mkpath }

    describe "#find" do
      context "when permissions files are present" do
        before(:each) do
          (instances_root/"myapp-staging").mkpath
          (instances_root/"yourapp-testing").mkpath
          File.write(instances_root/"permissions.yml", YAML.dump(all))
          File.write(instances_root/"myapp-staging"/"permissions.yml", YAML.dump(myapp_staging))
          File.write(instances_root/"yourapp-testing"/"permissions.yml", YAML.dump(yourapp_testing))
        end

        let(:data) { described_class.new(instances_root).find }

        it "finds global permissions" do
          expect(data[:all]).to eql("edit" => ["bhock"])
        end
        it "finds the non-global permissions" do
          expect(data[:instances]).to eql(
            "myapp-staging"=>{
              "deploy" => ["bhock"],
              "edit"   => ["aelkiss"]
            },
            "yourapp-testing"=>{
              "admin" => ["bhock", "aelkiss"],
              "edit"  => []
            }
          )
        end
      end

      context "when file structure uninitialized" do
        let(:data) { described_class.new(instances_root).find }

        it "global permissions are empty" do
          expect(data[:all]).to eql({})
        end
        it "non-global permissions are empty" do
          expect(data[:instances]).to eql({})
        end
      end

      context "when permission files present but empty" do
        before(:each) do
          (instances_root/"myapp-staging").mkpath
          (instances_root/"yourapp-testing").mkpath
          File.write(instances_root/"permissions.yml", "")
          File.write(instances_root/"myapp-staging"/"permissions.yml", "")
          File.write(instances_root/"yourapp-testing"/"permissions.yml", "")
        end

        let(:data) { described_class.new(instances_root).find }

        it "global permissions are empty" do
          expect(data[:all]).to eql({})
        end
        it "non-global permissions are present but not allowed" do
          expect(data[:instances]).to eql(
            "myapp-staging"=>{},
            "yourapp-testing"=>{}
          )
        end
      end
    end

    describe "#save" do
      it "saves the permissions to disk" do
        described_class.new(instances_root).save(permissions)
        expect(YAML.load(File.read(instances_root/"permissions.yml"))).to eql(all)
        expect(YAML.load(File.read(instances_root/"myapp-staging"/"permissions.yml")))
          .to eql(myapp_staging)
        expect(YAML.load(File.read(instances_root/"yourapp-testing"/"permissions.yml")))
          .to eql(yourapp_testing)
      end
    end
  end
end
