# frozen_string_literal: true

require_relative "../spec_helper"
require "moku/task/validate_pin"

# Note that Task::ValidatePin's direct dependencies are not under test. If
# those validators are extracted, they will need their own tests.
module Moku
  RSpec.describe Task::ValidatePin do
    include FakeFS::SpecHelpers
    let(:path) { Pathname.new("/some/path") }
    let(:artifact) { double(:artifact, path: path) }
    let(:task) { described_class.new }
    let(:status) { task.call(artifact) }

    before(:each) do
      FileUtils.mkdir_p path.to_s
      allow(artifact).to receive(:with_env).and_yield
    end

    context "without a .ruby-version file" do
      it { expect(status.success?).to be false }
      it "reports the issue" do
        expect(status.error).to match(/must supply a \.ruby-version file/)
      end
    end

    context "with an empty .ruby-version file" do
      before(:each) { File.write(path/".ruby-version", "") }

      it { expect(status.success?).to be false }
      it "reports the issue" do
        expect(status.error)
          .to match(/.ruby-version file must specify exactly MAJOR\.MINOR version/)
      end
    end

    context "with a .ruby-version file that specifies x.y.z version" do
      before(:each) { File.write(path/".ruby-version", "2.5.3") }

      it { expect(status.success?).to be false }
      it "reports the issue" do
        expect(status.error)
          .to match(/.ruby-version file must specify exactly MAJOR\.MINOR version/)
      end
    end

    context "with a .ruby-version file that specifies x.y version" do
      before(:each) { File.write(path/".ruby-version", "2.5") }

      context "without a Gemfile" do
        it { expect(status.success?).to be true }
      end

      context "with a Gemfile w/o a ruby directive" do
        before(:each) { File.write(path/"Gemfile", "") }

        it { expect(status.success?).to be true }
      end

      context "with a Gemfile w/ a x.y.z ruby directive" do
        before(:each) { File.write(path/"Gemfile", 'ruby "2.5.3"') }

        it { expect(status.success?).to be false }
        it "reports the issue" do
          expect(status.error)
            .to match(/ruby directive must specify exactly MAJOR\.MINOR version/)
        end
      end

      context "with a Gemfile w/ a x.y ruby directive" do
        before(:each) { File.write(path/"Gemfile", 'ruby "2.5"') }

        it { expect(status.success?).to be true }
      end
    end
  end
end
