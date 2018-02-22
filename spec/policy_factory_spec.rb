
# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/policy_factory"

module Fauxpaas
  RSpec.describe PolicyFactory do
    describe "#for" do
      it "requires a user_name" do
        expect{ described_class.new.for(nil, "foo-bar") }
          .to raise_error ArgumentError
      end

      it "requires an instance-name" do
        expect{ described_class.new.for("bhock", nil) }
          .to raise_error ArgumentError
      end

      it "propogates top level permissions downward" do
        policy = described_class.new(
          policy_type: Array,
          all: { "edit" => ["bhock"] },
          instances: {}
        ).for("bhock", "myapp-staging")
        expect(policy).to contain_exactly(:edit)
      end

      it "can handle missing permissions" do
        policy = described_class.new(
          policy_type: Array,
          all: { "edit" => ["bhock"] },
          instances: {
            "myapp-staging" => { "deploy" => ["bhock"] }
          }
        ).for("bhock", "myapp-staging")
        expect(policy).to contain_exactly(:edit, :deploy)
      end

      it "properly merges permissions" do
        policy = described_class.new(
          policy_type: Array,
          all: { "edit" => ["bhock"] },
          instances: {
            "myapp-staging" => { "deploy" => [], "edit" => [] }
          }
        ).for("bhock", "myapp-staging")
        expect(policy).to contain_exactly(:edit)
      end

    end

  end
end
