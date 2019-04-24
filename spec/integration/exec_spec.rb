# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/with_a_sandbox"
require_relative "../support/with_a_deployed_instance"
require "moku/command/exec"

module Moku

  RSpec.describe "integration exec", integration: true do
    include_context "with a sandbox", "test-norails"
    include_context "with a deployed instance", "test-norails"
    let(:deploy_dir) { deploy_root/"localhost"/"my"/"deploy"/"dir" } # see deploy.yml fixture
    let(:current_dir) { deploy_dir/"current" }

    before(:each) do
      allow(Moku.logger).to receive(:debug).and_call_original
    end

    def run_command(command, scope = Sites::Scope.once)
      Moku.invoker.add_command(
        Command::Exec.new(
          user: ENV["USER"],
          instance_name: "test-norails",
          cmd: command,
          scope: scope
        )
      )
    end

    it "is evaluated in the release directory" do
      run_command("touch exec_test_1")
      expect((current_dir/"exec_test_1").exist?).to be true
    end
  end

end
