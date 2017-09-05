require "spec_helper"

module Fauxpaas
  RSpec.describe VarFile do
    let(:fs) { double(:fs) }
    let(:existing_path) { double(:existing_path) }
    let(:new_path) { double(:new_path) }
    let(:contents) do
      {
        "a" => "ayy",
        "test" => "test",
        "primes" => [5,7,11,13],
        "nest" => {
          "foo" => "bar"
        }
      }
    end
    before(:each) do
      allow(fs).to receive(:exist?).with(existing_path).and_return true
      allow(fs).to receive(:exist?).with(new_path).and_return false
      allow(fs).to receive(:read).with(existing_path).and_return(contents.to_yaml)
      allow(fs).to receive(:write)
    end

    let(:var_file) { described_class.new(existing_path, fs) }
    describe "#list" do
      it "returns the contents" do
        expect(var_file.list).to eql(contents)
      end
      it "returns {} for a new file" do
        expect(described_class.new(new_path, fs).list).to eql({})
      end
    end

    describe "#add" do
      let(:key) { "zip" }
      let(:value) { ["a","b","c"] }
      it "adds the variable" do
        var_file.add(key, value)
        expect(var_file.list).to eql(contents.merge({ key => value}))
      end
    end

    describe "#remove" do
      let(:key) { contents.keys.first }
      it "removes the variable if it exists" do
        var_file.remove(key)
        contents.delete(key)
        expect(var_file.list).to eql(contents)
      end
      it "does not error if the variable is new" do
        expect{
          described_class.new(new_path, fs).remove("test")
        }.to_not raise_error
      end
    end

  end
end
