# frozen_string_literal: true

require_relative "./spec_helper"
require "fauxpaas/logged_releases"

module Fauxpaas
  RSpec.describe LoggedReleases do
    let(:release1) do
      double(
        :release1,
        to_brief_hash: {
          time:     "2017-01-31T13:44:11",
          user:     "alice",
          source:   "source7070a31ef4810af60b9df2d74bf09fb8e8",
          deploy:   "deploy7070a31ef4810af60b9df2d74bf09fb8e8",
          unshared: "unsha17070a31ef4810af60b9df2d74bf09fb8e8",
          shared:   "share17070a31ef4810af60b9df2d74bf09fb8e8"
        }
      )
    end

    describe "#to_s" do
      let(:instance) { described_class.new([release1]) }
      let(:expected) do
        File.read(Fauxpaas.root/"spec"/"fixtures"/"unit"/"releases_output_long.txt").chomp
      end
      it "returns a table" do
        expect(instance.to_s).to eq(expected)
      end
    end

    describe "#to_short_s" do
      let(:instance) { described_class.new([release1]) }
      let(:expected) do
        "| timestamp           | user  | source  | deployed w/ | dev     | infrastructure |\n" \
        "+---------------------+-------+---------+-------------+---------+----------------+\n" \
        "| 2017-01-31T13:44:11 | alice | source7 | deploy7     | unsha17 | share17        |"
      end
      it "returns a short table" do
        expect(instance.to_short_s).to eq(expected)
      end
    end
  end

end
