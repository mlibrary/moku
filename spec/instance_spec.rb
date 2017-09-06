require "spec_helper"
require "fauxpaas/instance"

module Fauxpaas
  RSpec.describe Instance do

    let(:app) { "myapp" }
    let(:stage) { "mystage" }
    let(:instance) { described_class.new("#{app}-#{stage}") }

    describe "#var_file" do
      let(:file_path) { Fauxpaas.instance_root + app + stage + "fauxpaas.yml" }
      it "returns the VarFile instance with the correct path" do
        expect(instance.var_file.path).to eql(file_path)
      end
    end

    describe "#config_files" do
      it "returns the ConfigFiles instance with the correct path" do
        expect(instance.config_files.path).to eql(instance.path)
      end
    end

  end
end