require "spec_helper"
require "fauxpaas/instance"

module Fauxpaas
  RSpec.describe Instance do

    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:instance) { described_class.new("#{app}-#{stage}") }

  end
end
