# frozen_string_literal: true

require "moku/shell/passthrough"
require "moku/status"
require "stringio"

module Moku
  RSpec.describe Shell::Passthrough do
    let(:log) { StringIO.new }
    let(:runner) { described_class.new(log) }

    describe "#run" do
      it "returns a status object" do
        status = runner.run("echo foo")
        expect(status).to be_a_kind_of(Status)
        expect(status.success?).to be true
      end

      it "prints stdout and stderr together" do
        runner.run("echo output; echo error >&2")
        log.rewind
        expect(log.read).to match(/output\nerror/)
      end

      it "prints output as it happens"
    end
  end
end
