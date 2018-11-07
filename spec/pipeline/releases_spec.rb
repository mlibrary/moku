# frozen_string_literal: true

require "moku/pipeline/releases"
require "moku/logged_releases"

module Moku

  RSpec.describe Pipeline::Releases do
    let(:logger) { double(:logger, info: nil) }
    let(:releases) { [1, 2, 3, 4] }
    let(:instance) { double(:instance, releases: releases) }
    let(:user) { "someuser" }
    let(:command) do
      double(
        instance: instance,
        user: user,
        long: false,
        logger: logger
      )
    end
    let(:pipeline) { described_class.new(command) }

    describe "#call" do
      let(:logged_releases) do
        double(:logged_releases, to_short_s: "some_string")
      end

      before(:each) do
        allow(LoggedReleases).to receive(:new).with([1, 2, 3, 4])
          .and_return(logged_releases)
      end

      it "logs the releases" do
        expect(logger).to receive(:info).with("\nsome_string")
        pipeline.call
      end
    end
  end

end
