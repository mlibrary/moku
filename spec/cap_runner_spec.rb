# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/cap_runner"

module Fauxpaas
  RSpec.describe CapRunner do
    RSpec::Matchers.define_negated_matcher :a_string_not_matching, :a_string_matching

    let(:success) { double(:success, success?: true) }
    let(:stdout) { double(:stdout) }
    let(:stderr) { double(:stderr) }
    let(:kernel) { double(:kernel, run: [stdout, stderr, success]) }

    let(:runner) { described_class.new("rails.capfile", kernel) }

    describe "#run" do
      it "runs the correct command" do
        expect(kernel).to receive(:run).with(
          "cap -f rails.capfile myapp-mystage test:task FOO=foo BAR=5 ZIP=zop"
        )
        runner.run("myapp-mystage", "test:task", {
          foo: "foo",
          bar: 5,
          zip: "zop"
        })
      end
      it "returns stdout, stderr, status" do
        expect(runner.run("myapp-mystage", "some:task", {}))
          .to eql([stdout, stderr, success])
      end
    end

  end
end

