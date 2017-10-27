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
    let(:path) { base_path + name + "instance.yml" }

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

    let(:contents_in) do
      YAML.dump(
        "deployer_env" => deployer_env,
        "default_branch" => default_branch,
      )
    end

    let(:contents_out) do
      YAML.dump(
        "deployer_env" => deployer_env,
        "default_branch" => default_branch,
        "releases" => []
      )
    end

    describe "#find" do
      it "returns the corresponding instance" do
        allow(fs).to receive(:read).with(path).and_return(contents_in)
        expect(repo.find(name)).to eql(instance)
      end

      context "with an instance that has been deployed" do
        let(:revision) { "c6a66de1b575c50ff94f3d5e8e358b0191e724df" }
        let(:contents_with_deploy) do
          YAML.dump(
            "deployer_env" => deployer_env,
            "default_branch" => default_branch,
            "releases" => [
              { 'src' => revision,
                'user' => 'somebody',
                'config' => '(none)',
                'deploy' => '(none)',
                'timestamp' => Time.now }
            ]
          )
        end

        before(:each) do
          allow(fs).to receive(:read).with(path).and_return(contents_with_deploy)
        end

        it "returns an instance with a release" do
          expect(repo.find(name).releases.length).to eql(1)
        end

        it "returns an instance with the correct release" do
          expect(repo.find(name).releases.first.src).to eql(revision)
        end
      end
    end

    describe "#save" do
      it "saves the instance to a yaml file" do
        expect(fs).to receive(:write).with(path, contents_out).and_return(nil)
        repo.save(instance)
      end

      context "with an instance that has been deployed" do
          let(:releases) { [double('deploy1', to_hash: {'foo' => 'bar'}),
                               double('deploy2', to_hash: {'baz' => 'quux'})] }
          let(:instance) do 
            Instance.new(name: name, 
                         deployer_env: deployer_env, 
                         default_branch: default_branch,
                         releases: releases)
          end
            
          let(:contents) do
            YAML.dump(
              "deployer_env" => deployer_env,
              "default_branch" => default_branch,
              "releases" => [ { "foo" => "bar" }, { "baz" => "quux" } ]
            )
          end

          it "saves the releases to a yaml file" do
            expect(fs).to receive(:write).with(path, contents).and_return(nil)
            repo.save(instance)
          end
      end
    end

  end
end
