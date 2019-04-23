require "moku/invoker"

module Moku

  RSpec.describe Invoker do
    let(:user) { double(:user) }
    let(:instance) { double(:instance) }
    let(:action) { double(:action) }
    let(:status) { double(:status) }
    let(:authority) { double(:authority) }
    let(:logger) { double(:logger, fatal: true) }
    let(:command) do
      double(
        :command,
        user: user,
        instance: instance,
        action: action,
        call: status
      )
    end

    let(:invoker) { described_class.new(authority: authority, logger: logger) }

    context "when the command is authorized" do
      before(:each) do
        allow(authority).to receive(:authorized?)
          .with(user: user, entity: instance, action: action)
          .and_return(true)
      end

      it "runs the command" do
        expect(invoker.add_command(command)).to eql(status)
      end
    end

    context "when the command is not authorized" do
      before(:each) do
        allow(authority).to receive(:authorized?)
          .with(user: user, entity: instance, action: action)
          .and_return(false)
      end

      it "logs the error" do
        expect(logger).to receive(:fatal).with(/is not authorized/)
        invoker.add_command(command)
      end
    end
  end

end
