# frozen_string_literal: true

require_relative "../support/a_command"
require "moku/command/command"

module Moku

  RSpec.describe Command::Command do
    include_context "when running a command spec"
    let(:command) { described_class.new(instance_name: instance_name, user: user) }

    it_behaves_like "a command"
  end

end
