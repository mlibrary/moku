# frozen_string_literal: true

require "fauxpaas/logged_releases"
require "fauxpaas/config"

module Fauxpaas
  RSpec.describe LoggedReleases do
    let(:release1) do
      double(
        :release1,
        to_brief_hash: {
          id:       "20170131134411999",
          version:  "v1.2.3",
          time:     "2017-01-31T13:44:11",
          user:     "alice",
          source:   "source7070a31ef4810af60b9df2d74bf09fb8e8",
          deploy:   "deploy7070a31ef4810af60b9df2d74bf09fb8e8",
          unshared: "unsha17070a31ef4810af60b9df2d74bf09fb8e8",
          shared:   "share17070a31ef4810af60b9df2d74bf09fb8e8"
        }
      )
    end
    let(:shared_name) { "infrastructure" }
    let(:unshared_name) { "dev" }
    let(:instance) do
      described_class.new(
        [release1],
        shared_name: shared_name,
        unshared_name: unshared_name
      )
    end

    describe "#to_s" do
      let(:expected) do
        File.read(Fauxpaas.root/"spec"/"fixtures"/"unit"/"releases_output_long.txt").chomp
      end

      it "returns a table" do
        expect(instance.to_s).to eq(expected)
      end
    end

    describe "#to_short_s" do
      # rubocop:disable Metrics/LineLength
      let(:expected) do
        "| id                | user  | version | source  | deployed w/ | dev     | infrastructure |\n" \
        "+-------------------+-------+---------+---------+-------------+---------+----------------+\n" \
        "| 20170131134411999 | alice | v1.2.3  | source7 | deploy7     | unsha17 | share17        |"
      end
      # rubocop:enable Metrics/LineLength

      it "returns a short table" do
        expect(instance.to_short_s).to eq(expected)
      end
    end
  end

end
