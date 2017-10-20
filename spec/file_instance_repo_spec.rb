require_relative "./spec_helper"
require "fauxpaas/file_instance_repo"
require "fauxpaas/instance"
require "yaml"
require "pathname"

module Fauxpaas
  RSpec.describe FileInstanceRepo do

    let(:base_path) { Pathname.new "/base/path" }
    let(:fs) { double(:fs, mkdir_p: nil)  }
    let(:repo) { described_class.new(base_path, fs) }
    let(:path) { base_path + "#{name}.yml" }

    let(:name) { "myapp-mystage" }
    let(:deployer_env) { "something" }
    let(:default_branch) { "somebranch" }
    let(:instance) do
      Instance.new(
        name: name,
        deployer_env: deployer_env,
        default_branch: default_branch
      )
    end

    let(:contents) do
      YAML.dump(
        "deployer_env" => deployer_env,
        "default_branch" => default_branch,
        "deployments" => []
      )
    end

    describe "#find" do
      it "returns the corresponding instance" do
        allow(fs).to receive(:read).with(path).and_return(contents)
        expect(repo.find(name)).to eql(instance)
      end
    end

    describe "#save" do
      it "saves the instance to a yaml file" do
        expect(fs).to receive(:write).with(path, contents).and_return(nil)
        repo.save(instance)
      end

      context "with an instance that has been deployed" do
          let(:deployments) { [double('deploy1', to_hash: {'foo' => 'bar'}),
                               double('deploy2', to_hash: {'baz' => 'quux'})] }
          let(:instance) do 
            Instance.new(name: name, 
                         deployer_env: deployer_env, 
                         default_branch: default_branch,
                         deployments: deployments)
          end
            
          let(:contents) do
            YAML.dump(
              "deployer_env" => deployer_env,
              "default_branch" => default_branch,
              "deployments" => [ { "foo" => "bar" }, { "baz" => "quux" } ]
            )
          end

          it "saves the deployments to a yaml file" do
            expect(fs).to receive(:write).with(path, contents).and_return(nil)
            repo.save(instance)
          end
      end
    end

  end
end
