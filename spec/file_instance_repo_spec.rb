require_relative "./spec_helper"
require "fauxpaas/file_instance_repo"
require "fauxpaas/instance"
require "yaml"

module Fauxpaas
  RSpec.describe FileInstanceRepo do

    let(:path) { "/base/path" }
    let(:fs) { double(:fs, mkdir_p: nil)  }
    let(:repo) { described_class.new(path, fs) }

    let(:name) { "myapp-mystage" }
    let(:deployer_env) { "something" }
    let(:instance) do
      Instance.new(name: name, deployer_env: deployer_env)
    end

    let(:contents) { YAML.dump("deployer_env" => deployer_env) }

    describe "#find" do
      it "returns the corresponding instance" do
        allow(fs).to receive(:read).with(path + instance.name)
          .and_return(contents)
        expect(repo.find(name)).to eql(instance)
      end
    end

    describe "#save" do
      it "saves the instance to a yaml file" do
        expect(fs).to receive(:write).with(path + instance.name, contents)
          .and_return(nil)
        repo.save(instance)
      end
    end

  end
end
