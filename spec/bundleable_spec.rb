# frozen_string_literal: true

require "moku/bundleable"

module Moku
  RSpec.describe Bundleable do
    class BundleableTest
      include Bundleable

      def initialize(path)
        @path = path
      end

      attr_reader :path

      def test_with_env
        with_env { yield }
      end
    end

    describe "#with_env" do
      let(:path) { Pathname.new(ENV["HOME"]) }
      let(:tester) { BundleableTest.new(path) }

      it "runs the command in the directory" do
        result = tester.test_with_env { Dir.pwd }
        expect(result.strip).to eql(path.to_s)
      end

      it "sheds the bundler context" do
        expect(Bundler).to receive(:with_clean_env).and_call_original
        tester.test_with_env { 1 }
      end
    end
  end
end
