# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/exec"
require "ostruct"

module Fauxpaas

  RSpec.describe Commands::Exec do
    include_context "a command spec"
    let(:env) {{foo: "bar", delicious: "sandwich"}}
    let(:role) { "app" }
    let(:command) do
      described_class.new(
        instance_name: instance_name,
        user: user,
        env: env,
        role: role,
        bin: "bundle",
        args: ["exec", "rake", "db:dostuff"]
      )
    end
    it_behaves_like "a command"

    it "action is :exec" do
      expect(command.action).to eql(:exec)
    end

    describe "#execute" do
      let(:instance) do
        double(:instance,
               interrogator: double(:interrogator,
                                    exec: OpenStruct.new(success?: true)))
      end
      it "tells cap to exec" do
        expect(instance.interrogator).to receive(:exec)
          .with(
            env: env,
            role: role,
            bin: "bundle",
            args: "exec rake db:dostuff"
          )
        command.execute
      end
    end
  end

end
