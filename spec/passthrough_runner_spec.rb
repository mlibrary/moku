# frozen_string_literal: true

require "fauxpaas/passthrough_runner"
require "stringio"

module Fauxpaas
  RSpec.describe PassthroughRunner do
    let(:log) { StringIO.new }
    let(:runner) { described_class.new(log) }
    describe "#run" do
      it "returns a status object" do
        _, _, status = runner.run("echo foo")
        expect(status).to be_a_kind_of(Process::Status)
        expect(status.success?).to be true
      end

      it "prints stdout and stderr together" do
        runner.run("echo output; echo error >&2")
        log.rewind
        expect(log.read).to match(/output\nerror/)
      end

      xit "returns stdout", pending: 'We always merge stdout and stderr for now; this could be enabled if PassthroughRunner gets a merge option' do
        stdout, _, _ = runner.run("echo output; echo error >&2")
        expect(stdout).not_to match(/error/)
      end

      xit "returns stderr", pending: 'We always merge stdout and stderr for now; this could be enabled if PassthroughRunner gets a merge option' do
        _, stderr, _ = runner.run("echo output; echo error >&2")
        expect(stderr).not_to match(/output/)
      end

      it "prints output as it happens"
    end
  end
end
