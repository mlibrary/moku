require_relative "./spec_helper"
require "fauxpaas/verbose_system_runner"

module Fauxpaas
  RSpec.describe VerboseSystemRunner do

    describe "#run" do
      let(:mock_runner) do
        double(:runner,
               run: ['stdout','stderr',double(:status)])
      end

      let(:command) { "/bin/something" }
      subject { described_class.new(runner: mock_runner).run(command) }

      it "emits the listed command" do
        expect { subject }.to output(/#{command}/).to_stdout
      end

      it "emits stdout from the command" do
        expect { subject }.to output(/stdout/).to_stdout
      end

      it "emits stderr from the command" do
        expect { subject }.to output(/stderr/).to_stdout
      end

      it "returns the same thing as its delegate" do
        expect(subject).to eql(mock_runner.run(command))
      end

      it "delegates running the command to the given runner" do
        expect(mock_runner).to receive(:run).with(command)
        subject
      end
    end
  end
end
