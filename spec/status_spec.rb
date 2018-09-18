require "spec_helper"
require "fauxpaas/status"

module Fauxpaas
  RSpec.describe Status do
    describe "::success" do
      it "returns a successful status" do
        expect(described_class.success).to eql(described_class.new(true))
      end
    end

    describe "::failure" do
      it "returns a failed status" do
        expect(described_class.failure("foo")) .to eql(described_class.new(false, "foo"))
      end
    end

    describe "#error" do
      let(:error) { "some_error" }
      let(:failure) { described_class.new(false, error) }
      it "returns the error" do
        expect(failure.error).to eql(error)
      end
    end

    describe "success?" do
      context "when successful" do
        let(:success) { described_class.new(true) }
        it { expect(success.success?).to be true }
      end
      context "when failed" do
        let(:error) { "some_error" }
        let(:failure) { described_class.new(false, error) }
        it { expect(failure.success?).to be false }
      end
    end

  end
end
