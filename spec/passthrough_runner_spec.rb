# frozen_string_literal: true

require "fauxpaas/passthrough_runner"
require "stringio"

module Fauxpaas
  RSpec.describe PassthroughRunner do
    let(:log) { StringIO.new }
    let(:runner) { described_class.new(log) }
    describe "#run" do
      it "returns a status object" do
        _, _, status= runner.run("echo foo")
        expect(status).to be_a_kind_of(Process::Status)
        expect(status.success?).to be true
      end

      it "prints stdout and stderr together" do
        runner.run("echo foo; ls nofile")
        log.rewind
        expect(log.read).to match(
          /foo\nls: cannot access '?nofile'?: No such file or directory\n/
        )
      end

      it "returns stdout" do
        stdout, _, _ = runner.run("echo foo; ls nofile")
        expect(stdout).to match(
          /foo\nls: cannot access '?nofile'?: No such file or directory\n/
        )
      end

      it "returns stderr" do
        _, stderr, _ = runner.run("echo foo; ls nofile")
        expect(stderr).to match(
          /foo\nls: cannot access '?nofile'?: No such file or directory\n/
        )
      end

      it "prints output as it happens"
    end
  end
end
