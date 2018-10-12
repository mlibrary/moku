# frozen_string_literal: true

require "fauxpaas/lazy/directory"
require "pathname"
require "fileutils"
require "find"

module Fauxpaas
  RSpec.describe Lazy::Directory do
    class TestFile
      attr_reader :path
      def initialize(path)
        @path = Pathname.new(path)
      end

      def cp(dest)
        self.class.new(dest)
      end

      def relative_from(base)
        self.class.new(path.relative_path_from(base))
      end

      def merge(_other)
        self.class.new(path/"MERGED")
      end

      def eql?(other)
        path == other.path
      end
      alias_method :==, :eql?
    end

    let(:files) do
      [
        TestFile.new(path/"bar.txt"),
        TestFile.new(path/"collide.txt")
      ]
    end
    let(:base_path) { Pathname.new("lhs") }
    let(:path) { base_path/"foo" }
    let(:directory) { described_class.new(path, files) }

    describe "::for" do
      before(:each) { allow(Find).to receive(:find).and_return(raw_files) }

      let(:raw_files) do
        [
          "#{path}/bar.txt",
          "#{path}/collide.txt"
        ]
      end

      it "wraps the path in a pathname" do
        expect(described_class.for(path).path).to eql(Pathname.new(path))
      end

      it "creates an instance with path" do
        expect(described_class.for(path).path).to eql(path)
      end

      # This behavior requires mocking the filesystem
      xit "stores the files" do
        expect(described_class.for(path).files).to contain_exactly(*files)
      end
    end

    describe "#relative_from" do
      it "returns a new instance with the relative path" do
        expect(directory.relative_from(base_path).path)
          .to eql(path.relative_path_from(base_path))
      end

      it "does not change the files" do
        expect(directory.relative_from(base_path).files)
          .to eql(files.map {|f| f.relative_from(base_path) })
      end
    end

    describe "#add" do
      let(:new_path) { Pathname.new("new/path") }
      let(:new_file) { TestFile.new(new_path/"baz.txt") }

      it "returns a new instance" do
        expect(directory.add(new_file)).to be_an_instance_of described_class
      end

      it "copies the file" do
        expect(directory.add(new_file).files)
          .to include(TestFile.new(path/"baz.txt"))
      end
    end

    describe "#cp" do
      let(:new_path) { Pathname.new("new/path") }

      it "returns a new instance at the new path" do
        expect(directory.cp(new_path).path).to eql(new_path)
      end

      it "copies the files" do
        expect(directory.cp(new_path).files).to contain_exactly(
          TestFile.new("new/path/bar.txt"),
          TestFile.new("new/path/collide.txt")
        )
      end
    end

    describe "#write" do
      let(:files) do
        [
          double(:file1, write: "wrote1"),
          double(:file2, write: "wrote2")
        ]
      end

      before(:each) { allow(::FileUtils).to receive(:mkdir_p) }

      it "creates the directory" do
        expect(::FileUtils).to receive(:mkdir_p).with path
        directory.write
      end

      it "returns a new instance having written each file" do
        expect(directory.write.files).to contain_exactly("wrote1", "wrote2")
      end

      it "returns a new instance at the path" do
        expect(directory.write.path).to eql(path)
      end
    end

    describe "#merge" do
      let(:path) { Pathname.new("lhs/lhs") }
      let(:files) do
        [
          TestFile.new(path/"bar.txt"),
          TestFile.new(path/"collide.txt")
        ]
      end
      let(:other_path) { Pathname.new("rhs") }
      let(:other_files) do
        [
          TestFile.new(other_path/"foobar.txt"),
          TestFile.new(other_path/"collide.txt")
        ]
      end
      let(:directory) { described_class.new(path, files) }
      let(:other) { described_class.new(other_path, other_files) }

      it "returns a new instance at the original path" do
        expect(directory.merge(other).path).to eql(path)
      end

      it "skips merging files without a collision" do
        expect(directory.merge(other).files)
          .to include(
            TestFile.new(path/"bar.txt"),
            TestFile.new(path/"foobar.txt")
          )
      end

      it "merges files with a collision" do
        # Note that appending the MERGED text is just for our test case
        expect(directory.merge(other).files)
          .to include(
            TestFile.new(path/"collide.txt").merge(TestFile.new(other_path/"collide.txt"))
          )
      end
    end
  end
end
