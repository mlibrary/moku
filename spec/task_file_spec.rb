# frozen_string_literal: true

require "moku/task_file"
require "moku/sites/scope"
require "fakefs/spec_helpers"
require "pathname"
require "yaml"

module Moku
  RSpec.describe TaskFile do
    include FakeFS::SpecHelpers

    let(:content) { [{ "cmd" => "foo" }, { "cmd" => "bar" }] }
    let(:path) { Pathname.new("/path.yml") }
    let(:task_file) { described_class.new(path) }

    before(:each) do
      File.write(path.to_s, YAML.dump(content))
    end

    describe "enumerability" do
      it "returns the tasks" do
        expect(task_file.map {|x| x }).to contain_exactly(
          { cmd: "foo", scope: an_instance_of(Sites::Scope) },
          cmd: "bar", scope: an_instance_of(Sites::Scope)
        )
      end
    end
  end
end
