# frozen_string_literal: true

require_relative "spec_helper"
require "fakefs/spec_helpers"
require "fauxpaas/task_file"
require "pathname"

module Fauxpaas
  RSpec.describe TaskFile do
    include FakeFS::SpecHelpers

    SomeTask = Struct.new(:command)
    let(:content) { [{"cmd" => "foo"}, {"cmd" => "bar"}] }
    let(:path) { Pathname.new("/path.yml") }
    let(:task_file) { described_class.new(path, task_type: SomeTask) }

    before(:each) do
      File.write(path.to_s, YAML.dump(content))
    end

    describe "#tasks" do
      it "returns the tasks" do
        expect(task_file.tasks).to match_array([
          SomeTask.new("foo"),
          SomeTask.new("bar")
        ])
      end
    end

  end
end
