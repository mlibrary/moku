# frozen_string_literal: true

require "moku/sites"
require "moku/sites/scope"

module Moku
  RSpec.describe Sites do
    let(:macc_hash) do
      {
        "macc" => [
          "macc1",
          { hostname: "macc2" }
        ]
      }
    end
    let(:ictc_hash) do
      {
        "ictc" => [
          { hostname: "ictc1" },
          "ictc2"
        ]
      }
    end
    let(:hash) { macc_hash.merge(ictc_hash) }
    let(:sites) { described_class.new(hash) }

    describe "#hosts" do
      it "returns all hosts" do
        expect(sites.hosts).to contain_exactly(
          Sites::Host.new("macc1"),
          Sites::Host.new("macc2"),
          Sites::Host.new("ictc1"),
          Sites::Host.new("ictc2")
        )
      end
    end

    describe "#primaries" do
      it "returns the first host from each site" do
        expect(sites.primaries).to contain_exactly(
          Sites::Host.new("macc1"),
          Sites::Host.new("ictc1")
        )
      end
    end

    describe "#primary" do
      it "returns the first host only" do
        expect(sites.primary).to eql(Sites::Host.new("macc1"))
      end
    end

    describe "#site" do
      it "returns the named site" do
        expect(sites.site("macc")).to eql(
          described_class.new(macc_hash)
        )
      end
    end

    describe "#host" do
      context "when the named host exists" do
        let(:host) { "macc2" }

        it "returns the named host" do
          expect(sites.host(host)).to eql([Sites::Host.new("macc2")])
        end
      end

      context "when the named host doesn't exixt" do
        let(:host) { "fake47" }

        it "returns no hosts" do
          expect(sites.host(host)).to eql([])
        end
      end
    end

    describe Sites::Scope do
      let(:sites) { Sites.new(hash) }

      describe "::all" do
        let(:scope) { described_class.all }

        it "returns all hosts" do
          expect(scope.apply(sites)).to contain_exactly(
            Sites::Host.new("macc1"),
            Sites::Host.new("macc2"),
            Sites::Host.new("ictc1"),
            Sites::Host.new("ictc2")
          )
        end
      end

      describe "::each_site" do
        let(:scope) { described_class.each_site }

        it "returns one host per site" do
          expect(scope.apply(sites)).to contain_exactly(
            Sites::Host.new("macc1"),
            Sites::Host.new("ictc1")
          )
        end
      end

      describe "::once" do
        let(:scope) { described_class.once }

        it "returns one host" do
          expect(scope.apply(sites)).to contain_exactly(
            Sites::Host.new("macc1")
          )
        end
      end

      describe "::site" do
        it "returns the specified site's hosts" do
          expect(described_class.site("macc").apply(sites)).to contain_exactly(
            Sites::Host.new("macc1"),
            Sites::Host.new("macc2")
          )
        end
        it "returns the specified sites' hosts" do
          expect(described_class.site("macc", "ictc").apply(sites)).to contain_exactly(
            Sites::Host.new("macc1"),
            Sites::Host.new("macc2"),
            Sites::Host.new("ictc1"),
            Sites::Host.new("ictc2")
          )
        end
      end

      describe "::host" do
        it "returns the specified site's hosts" do
          expect(described_class.host("macc2").apply(sites)).to contain_exactly(
            Sites::Host.new("macc2")
          )
        end
        it "returns the specified sites' hosts" do
          expect(described_class.host("macc1", "ictc2").apply(sites)).to contain_exactly(
            Sites::Host.new("macc1"),
            Sites::Host.new("ictc2")
          )
        end
      end
    end
  end
end
