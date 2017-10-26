require_relative "./spec_helper"
require "fauxpaas/deployment"

module Fauxpaas
  SOME_COMMIT = "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33"
  SOME_OTHER_COMMIT = "f49cf6381e322b147053b74e4500af8533ac1e4c"
  DEFAULT_COMMIT = "(none)"

  RSpec.describe Deployment do
    describe '#initialize' do
      it "can accept the commit identifier of the source code deployed" do
        expect(described_class.new(SOME_COMMIT)).not_to be_nil
      end

      it "can optionally accept a timestamp" do
        expect(described_class.new(SOME_COMMIT, timestamp: Time.now)).not_to be_nil
      end

      it "can optionally accept a user" do
        expect(described_class.new(SOME_COMMIT, user: 'somebody')).not_to be_nil
      end

      it "can optionally accept a developer config" do
        expect(described_class.new(SOME_COMMIT, dev_config: double('dev_config'))).not_to be_nil
      end

      it "can optionally accept a deploy config" do
        expect(described_class.new(SOME_COMMIT, dev_config: double('deploy_config'))).not_to be_nil
      end
    end

    describe '#user' do
      it "returns the given user" do
        expect(described_class.new(SOME_COMMIT,user:'baruser').user).to eq('baruser')
      end
    end

    describe '#timestamp' do
      it "returns the current timestamp by default" do
        expect(described_class.new(SOME_COMMIT).timestamp).to be_within(0.1).of(Time.now)
      end

      it "returns the given timestamp" do
        sometime = Time.at(9999)
        expect(described_class.new(SOME_COMMIT,timestamp: sometime).timestamp).to eq(sometime)
      end
    end

    describe '#src' do
      it "returns the given commit identifier" do
        expect(described_class.new(SOME_COMMIT).src).to eq(SOME_COMMIT)
      end
    end

    describe "#dev_config" do
      it "returns the given commit identifier" do
        expect(described_class.new(SOME_COMMIT,dev_config: SOME_OTHER_COMMIT).dev_config).to eq(SOME_OTHER_COMMIT)
      end

      it "defaults to (none)" do
        expect(described_class.new(SOME_COMMIT).dev_config).to eq('(none)')
      end
    end

    describe "#deploy_config" do
      it "returns the given commit identifier" do
        expect(described_class.new(SOME_COMMIT,deploy_config: SOME_OTHER_COMMIT).deploy_config).to eq(SOME_OTHER_COMMIT)
      end

      it "defaults to (none)" do
        expect(described_class.new(SOME_COMMIT).deploy_config).to eq('(none)')
      end
    end

    context "with a fully-specified instance" do
      let(:time) { Time.at(9999) }
      let(:instance) do
        described_class.new(SOME_COMMIT,timestamp: time,
                            user: 'foouser',
                            dev_config: SOME_OTHER_COMMIT,
                            deploy_config: SOME_OTHER_COMMIT)
      end
      describe '#to_hash' do
        it "returns a hash of the given parameters with the sha1sum of dev & deploy configs" do

          expect(instance.to_hash).to eq( { 'src' =>  SOME_COMMIT,
                                            'user' => 'foouser',
                                            'config' => SOME_OTHER_COMMIT,
                                            'deploy' => SOME_OTHER_COMMIT,
                                            'timestamp' => time })
        end
      end

      describe '#to_s' do
        it "returns a formatted version of the parameters with the sha1sum of dev & deploy configs" do
          expect(instance.to_s).to eq( "#{time}: foouser deployed #{SOME_COMMIT} #{SOME_OTHER_COMMIT} with #{SOME_OTHER_COMMIT}" )
        end
      end

    end

    describe '#from_hash' do
      it "correctly deserializes from a hash" do
        time = Time.at(9999)
        instance = described_class.from_hash ( {
          'src' => SOME_COMMIT,
          'user' => 'foouser',
          'config' => SOME_OTHER_COMMIT,
          'deploy' => SOME_OTHER_COMMIT,
          'timestamp' => time })

        expect(instance.src).to eq(SOME_COMMIT)
        expect(instance.user).to eq('foouser')
        expect(instance.dev_config).to eq(SOME_OTHER_COMMIT)
        expect(instance.deploy_config).to eq(SOME_OTHER_COMMIT)
        expect(instance.timestamp).to eq(time)
      end
    end

  end
end
