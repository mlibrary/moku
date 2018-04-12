# frozen_string_literal: true

require "fauxpaas/invoker"

module Fauxpaas
  class TestCommand
    def initialize(validity)
      @validity = validity
      @executed = false
    end

    def missing
      ["foo", "bar"]
    end

    def valid?
      @validity
    end

    def executed?
      @executed
    end

    def execute
      @executed = true
    end
  end

  RSpec.describe Invoker do
    let(:invoker) { described_class.new }
    let(:valid_command) { TestCommand.new(true) }
    let(:invalid_command) { TestCommand.new(false) }
    describe "#add_command" do
      context "with a valid command" do
        let(:command) { valid_command }
        it "runs the command immediately" do
          expect { invoker.add_command(command) }
            .to change { command.executed? }
            .from(false)
            .to(true)
        end
      end

      context "with an invalid command" do
        let(:command) { invalid_command }
        it "raises an KeyError with the missing keys" do
          expect do
            invoker.add_command(command)
          end.to raise_error(KeyError, "Missing keys: foo, bar")
        end
        it "does not run the command" do
          expect do
            begin
              invoker.add_command(command)
            rescue StandardError
            end
          end.to_not change { command.executed? }
        end
      end
    end
  end
end
