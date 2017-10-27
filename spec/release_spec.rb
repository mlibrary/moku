# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/release"

module Fauxpaas
  RSpec.describe Release do
    let(:some_commit) {  "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33" }
    let(:some_other_commit) { "f49cf6381e322b147053b74e4500af8533ac1e4c" }

    describe "#initialize" do
      it "can accept the commit identifier of the source code deployed" do
        expect(described_class.new(some_commit)).not_to be_nil
      end

      it "can optionally accept a timestamp" do
        expect(described_class.new(some_commit, timestamp: Time.now)).not_to be_nil
      end

      it "can optionally accept a user" do
        expect(described_class.new(some_commit, user: "somebody")).not_to be_nil
      end

      it "can optionally accept a developer config" do
        expect(described_class.new(some_commit, dev_config: double("dev_config"))).not_to be_nil
      end

      it "can optionally accept a deploy config" do
        expect(described_class.new(some_commit, dev_config: double("deploy_config"))).not_to be_nil
      end
    end

    describe "#user" do
      it "returns the given user" do
        expect(described_class.new(some_commit, user: "baruser").user).to eq("baruser")
      end
    end

    describe "#timestamp" do
      it "returns the current timestamp by default" do
        expect(described_class.new(some_commit).timestamp).to be_within(0.1).of(Time.now)
      end

      it "returns the given timestamp" do
        sometime = Time.at(9999)
        expect(described_class.new(some_commit, timestamp: sometime).timestamp).to eq(sometime)
      end
    end

    describe "#src" do
      it "returns the given commit identifier" do
        expect(described_class.new(some_commit).src).to eq(some_commit)
      end
    end

    describe "#dev_config" do
      it "returns the given commit identifier" do
        expect(described_class.new(some_commit, dev_config: some_other_commit).dev_config).to eq(some_other_commit)
      end

      it "defaults to (none)" do
        expect(described_class.new(some_commit).dev_config).to eq("(none)")
      end
    end

    describe "#deploy_config" do
      it "returns the given commit identifier" do
        expect(described_class.new(some_commit, deploy_config: some_other_commit).deploy_config).to eq(some_other_commit)
      end

      it "defaults to (none)" do
        expect(described_class.new(some_commit).deploy_config).to eq("(none)")
      end
    end

    context "with a fully-specified instance" do
      let(:time) { Time.at(9999) }
      let(:instance) do
        described_class.new(some_commit, timestamp: time,
                            user: "foouser",
                            dev_config: some_other_commit,
                            deploy_config: some_other_commit)
      end
      describe "#to_hash" do
        it "returns a hash of the given parameters with the sha1sum of dev & deploy configs" do
          expect(instance.to_hash).to eq("src" =>  some_commit,
                                            "user" => "foouser",
                                            "config" => some_other_commit,
                                            "deploy" => some_other_commit,
                                            "timestamp" => time)
        end
      end

      describe "#to_s" do
        it "returns a formatted version of the parameters with the sha1sum of dev & deploy configs" do
          expect(instance.to_s).to eq("#{time}: foouser deployed #{some_commit} #{some_other_commit} with #{some_other_commit}")
        end
      end
    end

    describe "#from_hash" do
      it "correctly deserializes from a hash" do
        time = Time.at(9999)
        instance = described_class.from_hash ( {
          "src"       => some_commit,
          "user"      => "foouser",
          "config"    => some_other_commit,
          "deploy"    => some_other_commit,
          "timestamp" => time
        })

        expect(instance.src).to eq(some_commit)
        expect(instance.user).to eq("foouser")
        expect(instance.dev_config).to eq(some_other_commit)
        expect(instance.deploy_config).to eq(some_other_commit)
        expect(instance.timestamp).to eq(time)
      end
    end
  end
end
