# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/step_list"
require "pathname"

module Fauxpaas
  RSpec.describe StepList do
    let(:cmd1) {{"cmd" => "foo"}}
    let(:cmd2) {{"cmd" => "bar"}}
    let(:content) { [cmd1, cmd2] }
    let(:step_list) { described_class.new(content) }

    describe "#steps" do
      it "returns the steps" do
        expect(step_list.steps.map{|s| s.cmd}).to match_array(["foo", "bar"])
      end
    end
  end
end
