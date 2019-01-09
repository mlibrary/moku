# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/with_a_sandbox"
require_relative "../support/with_a_deployed_instance"
require "moku/command/releases"
require "moku/command/rollback"

module Moku

  RSpec.describe "integration releases", integration: true do
    include_context "with a sandbox", "test-norails"
    include_context "with a deployed instance", "test-norails"
    include_context "with a deployed instance", "test-norails"
    before(:all) do # rubocop:disable RSpec/BeforeAfterAll
      Moku.invoker.add_command(
        Command::Rollback.new(
          user: ENV["USER"],
          instance_name: "test-norails"
        )
      )
    end

    before(:each) do
      allow(Moku.logger).to receive(:info).and_call_original
    end

    def get_releases(long:)
      Moku.invoker.add_command(
        Command::Releases.new(
          user: ENV["USER"],
          instance_name: "test-norails",
          long: long
        )
      )
    end

    context "with long releases output" do
      it "displays rollbacks in the list of releases" do
        expect(Moku.logger).to receive(:info) do |string|
          recent = string.split("\n")[3]
          expect(recent).to match(/\| rollback -> #{Time.now.strftime("%Y%m%d")}/)
        end
        get_releases(long: true)
      end
    end

    context "with short releases output" do
      let(:long) { false }

      it "displays rollbacks in the list of releases" do
        expect(Moku.logger).to receive(:info) do |string|
          recent = string.split("\n")[3]
          expect(recent).to match(/\| -> #{Time.now.strftime("%Y%m%d")}/)
        end
        get_releases(long: false)
      end
    end
  end
end
