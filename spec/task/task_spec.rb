# frozen_string_literal: true

require "moku/task/task"
require "pathname"

module Moku
  RSpec.describe Task::Task do
    describe "#to_s" do
      it "returns the class name" do
        expect(described_class.new.to_s).to eql(described_class.to_s)
      end
    end
  end
end
