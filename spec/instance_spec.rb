require "spec_helper"
require "fauxpaas/instance"

module Fauxpaas
  RSpec.describe Instance do

    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:instance) { described_class.new("#{app}-#{stage}") }

    describe "#var_file" do
      let(:path) { Fauxpaas.instance_root + app + stage + "fauxpaas.yml" }
      it "returns the VarFile instance with the correct path" do
        expect(instance.var_file.path).to eql(path)
      end
    end

  end
end