# frozen_string_literal: true

require "moku/command/deploy"

module Moku
  # Deploy an instance. This should only be invoked in the "with a sandbox"
  # context.
  RSpec.shared_context "with a deployed instance" do |instance_name|
    before(:all) do
      Moku.invoker.add_command(
        Command::Deploy.new(
          user: ENV["USER"],
          instance_name: instance_name,
          reference: nil
        )
      )
    end
  end
end
