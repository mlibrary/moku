# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/cap_runner"

module Fauxpaas
  RSpec.describe CapRunner do
    let(:success) { double(:success, success?: true) }
    let(:stdout) { double(:stdout) }
    let(:stderr) { double(:stderr) }
    let(:kernel) { double(:kernel, run: [stdout, stderr, success]) }

    let(:capfile_path) { "/path/to/capfile/x.capfile" }
    let(:runner) { described_class.new(kernel) }

    describe "#run" do
      it "runs the correct command" do
        expect(kernel).to receive(:run).with(
          "bin/cap -f #{capfile_path} myapp-mystage test:task --trace FOO=foo BAR=5 ZIP=zop"
        )
        runner.run(capfile_path, "myapp-mystage", "test:task",
          foo: "foo",
          bar: 5,
          zip: "zop")
      end

      it "quotes environment variable values" do
        expect(kernel).to receive(:run).with(
          "bin/cap -f #{capfile_path} " + 'myapp-mystage test:task --trace FOO=with\\ spaces ' \
          'BAR=with\\ double\\"\\ quotes BAZ=\\$horrible\\ \\`arg\\` ' \
          'QUUX=with\\\\backslash'
        )
        runner.run(capfile_path, "myapp-mystage", "test:task",
          foo: "with spaces",
          bar: 'with double" quotes',
          baz: "$horrible `arg`",
          quux: "with\\backslash")
      end

      it "returns stdout, stderr, status" do
        expect(runner.run(capfile_path, "myapp-mystage", "some:task", {}))
          .to eql([stdout, stderr, success])
      end
    end
  end
end
