# frozen_string_literal: true

require_relative "spec_helper"
require "fauxpaas/artifact"

module Fauxpaas
  RSpec.describe Artifact do
    let(:source_path) { double(:source_path) }
    let(:shared_path) { double(:shared_path) }
    let(:unshared_path) { double(:unshared_path) }

    let(:built_release) { described_class.new(source_path: source_path,
                                              shared_path: shared_path,
                                              unshared_path: unshared_path) }

    it "can be constructed" do
      expect(built_release).not_to be_nil
    end

    [:source_path,:shared_path,:unshared_path].each do |attr|
      describe "##{attr}" do
        it "returns the #{attr}" do
          expect(built_release.public_send(attr)).to eq(self.public_send(attr))
        end
      end
    end
  end
end
