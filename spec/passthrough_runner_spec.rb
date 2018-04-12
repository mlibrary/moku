# frozen_string_literal: true

require "fauxpaas/passthrough_runner"
require "stringio"

module Fauxpaas
  RSpec.describe PassthroughRunner do
    let(:log) { StringIO.new }
    let(:runner) { described_class.new(log) }
    describe "#run" do
      it "returns a status object" do
        result = runner.run("echo foo")
        expect(result).to be_a_kind_of(Process::Status)
        expect(result.success?).to be true
      end

      it "prints stdout and stderr together" do
        runner.run("echo foo; ls nofile")
        log.rewind
        expect(log.read).to eql(
          "foo\nls: cannot access 'nofile': No such file or directory\n"
        )
      end

      it "prints outout as it happens"
    end
  end
end
