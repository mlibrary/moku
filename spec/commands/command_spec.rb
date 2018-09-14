# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/a_command"
require "fauxpaas/commands/command"

module Fauxpaas

  RSpec.describe Commands::Command do
    include_context "a command spec"
    let(:command) { described_class.new(instance_name: instance_name, user: user) }
    it_behaves_like "a command"
  end

end
