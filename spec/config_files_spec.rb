require "spec_helper"
require_relative "support/memory_filesystem"
require "fauxpaas/config_files"

module Fauxpaas
  RSpec.describe ConfigFiles do
    let(:path) { Fauxpaas.instance_root + "config_files_test" }
    let(:files_path) { path + "files" }
    let(:fs) { MemoryFilesystem.new }
    let(:config_files) { described_class.new(path, fs) }

    describe "#list" do
      it "returns {} when empty" do
        expect(config_files.list).to eql({})
      end
    end

    describe "#add" do
      let(:filename) { "foo.yml" }
      let(:app_path) { "config/bar.yml" }
      let(:contents) { "some\ncontents\n\n\tsad\n" }
      it "adds the file to the list" do
        config_files.add(filename, app_path, contents)
        expect(config_files.list).to eql({app_path => filename})
      end
      it "writes the file" do
        config_files.add(filename, app_path, contents)
        expect(fs.read(files_path + filename)).to eql(contents)
      end
      it "is idempotent" do
        expect {
          config_files.add(filename, app_path, contents)
          config_files.add(filename, app_path, contents)
        }.to_not raise_error
      end
    end

    describe "#remove" do
      let(:filename) { "foo.yml" }
      let(:app_path) { "config/bar.yml" }
      let(:contents) { "some\ncontents\n\n\tsad\n" }
      before(:each) { config_files.add(filename, app_path, contents) }
      it "removes the file from the list" do
        config_files.remove(app_path)
        expect(config_files.list).to eql({})
      end
      it "removes the file" do
        config_files.remove(app_path)
        expect(fs.read(files_path + filename)).to be_nil
      end
      it "is idempotent" do
        expect {
          config_files.remove(app_path)
          config_files.remove(app_path)
        }.to_not raise_error
      end
    end

    describe "#move" do
      let(:filename) { "foo.yml" }
      let(:app_path) { "config/bar.yml" }
      let(:new_app_path) { "config/bar.d/baz.yml" }
      let(:contents) { "some\ncontents\n\n\tsad\n" }
      before(:each) { config_files.add(filename, app_path, contents) }

      it "changes the list" do
        config_files.move(app_path, new_app_path)
        expect(config_files.list).to eql(new_app_path => filename)
      end
    end

  end
end
