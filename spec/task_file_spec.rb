# frozen_string_literal: true

require "moku/task_file"
require "moku/sites/scope"
require "pathname"
require "yaml"

module Moku
  RSpec.describe TaskFile do
    let(:content) { [{ "cmd" => "foo" }, { "cmd" => "bar" }] }
    let(:task_file) { described_class.new(content) }

    describe "enumerability" do
      it "returns the tasks" do
        expect(task_file.map(&:command)).to contain_exactly("foo", "bar")
      end

      it "returns TaskSpec instances" do
        expect(task_file.map {|x| x }).to contain_exactly(
          TaskFile::TaskSpec.new("foo", Sites::Scope.all),
          TaskFile::TaskSpec.new("bar", Sites::Scope.all)
        )
      end
    end
  end
end
