# frozen_string_literal: true

require "fauxpaas"

module Fauxpaas
  RSpec.shared_context "a mock instance" do
    let(:mock_instance) { instance_double(Instance) }

    let(:mock_instance_repo) do
      instance_double(FileInstanceRepo,
        save: true,
        find: mock_instance)
    end

    before(:each) do
      Fauxpaas.instance_repo = mock_instance_repo
    end

    after(:each) do
      Fauxpaas.instance_repo = nil
    end
  end
end
