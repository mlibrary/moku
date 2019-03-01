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
          { hostname: "ictc1", user: another_user },
          "ictc2"
        ]
      }
    end
    let(:user) { "someuser" }
    let(:another_user) { "anotheruser" }
    let(:hash) { macc_hash.merge(ictc_hash).merge(user: user) }
    let(:sites) { described_class.for(hash) }

    let(:reverse_hash) do
      {
        "user"  => user,
        "nodes" => [
          { "ictc1" => "ictc" },
          { "ictc2" => "ictc" },
          { "macc1" => "macc" }
        ]
      }
    end

    let(:reverse_hash_symbolized) do
      {
        user:  user,
        nodes: [
          { macc1: "macc" }
        ]
      }
    end

    describe "::for" do
      it "handles a site:[hosts] hash" do
        expect(described_class.for(hash).hosts).to contain_exactly(
          Sites::Host.new("macc1", user),
          Sites::Host.new("macc2", user),
          Sites::Host.new("ictc1", another_user),
          Sites::Host.new("ictc2", user)
        )
      end

      it "handles a list of host:site" do
        expect(described_class.for(reverse_hash).hosts).to contain_exactly(
          Sites::Host.new("ictc1", user),
          Sites::Host.new("ictc2", user),
          Sites::Host.new("macc1", user)
        )
      end

      it "handles a list of host:site with symbolized hostnames" do
        expect(described_class.for(reverse_hash_symbolized).hosts).to contain_exactly(
          Sites::Host.new("macc1", user)
        )
      end
    end

    describe "#to_h" do
      it "canonicalizes a site:[hosts] hash" do
        expect(described_class.for(hash).to_h).to eq(
          "user" => user,
          "ictc" => [
            { hostname: "ictc1", user: another_user },
            "ictc2"
          ],
          "macc" => ["macc1", "macc2"]
        )
      end

      it "converts a list of host:site to a site:[hosts] hash" do
        expect(described_class.for(reverse_hash).to_h).to eq(
          "user" => user,
          "ictc" => ["ictc1", "ictc2"],
          "macc" => ["macc1"]
        )
      end
    end

    describe "#hosts" do
      it "returns all hosts" do
        expect(sites.hosts).to contain_exactly(
          Sites::Host.new("macc1", user),
          Sites::Host.new("macc2", user),
          Sites::Host.new("ictc1", another_user),
          Sites::Host.new("ictc2", user)
        )
      end
    end

    describe "#primaries" do
      it "returns the first host from each site" do
        expect(sites.primaries).to contain_exactly(
          Sites::Host.new("macc1", user),
          Sites::Host.new("ictc1", another_user)
        )
      end
    end

    describe "#primary" do
      it "returns the first host only" do
        expect(sites.primary).to eql(Sites::Host.new("macc1", user))
      end
    end

    describe "#site" do
      it "returns the named site" do
        expect(sites.site("macc")).to eql(
          described_class.for(macc_hash.merge(user: user))
        )
      end
    end

    describe "#host" do
      context "when the named host exists" do
        let(:host) { "macc2" }

        it "returns the named host" do
          expect(sites.host(host)).to eql([Sites::Host.new("macc2", user)])
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
      let(:sites) { Sites.for(hash) }

      describe "::all" do
        let(:scope) { described_class.all }

        it "returns all hosts" do
          expect(scope.apply(sites)).to contain_exactly(
            Sites::Host.new("macc1", user),
            Sites::Host.new("macc2", user),
            Sites::Host.new("ictc1", another_user),
            Sites::Host.new("ictc2", user)
          )
        end
      end

      describe "::each_site" do
        let(:scope) { described_class.each_site }

        it "returns one host per site" do
          expect(scope.apply(sites)).to contain_exactly(
            Sites::Host.new("macc1", user),
            Sites::Host.new("ictc1", another_user)
          )
        end
      end

      describe "::once" do
        let(:scope) { described_class.once }

        it "returns one host" do
          expect(scope.apply(sites)).to contain_exactly(
            Sites::Host.new("macc1", user)
          )
        end
      end

      describe "::site" do
        it "returns the specified site's hosts" do
          expect(described_class.site("macc").apply(sites)).to contain_exactly(
            Sites::Host.new("macc1", user),
            Sites::Host.new("macc2", user)
          )
        end
        it "returns the specified sites' hosts" do
          expect(described_class.site("macc", "ictc").apply(sites)).to contain_exactly(
            Sites::Host.new("macc1", user),
            Sites::Host.new("macc2", user),
            Sites::Host.new("ictc1", another_user),
            Sites::Host.new("ictc2", user)
          )
        end
      end

      describe "::host" do
        it "returns the specified site's hosts" do
          expect(described_class.host("macc2").apply(sites)).to contain_exactly(
            Sites::Host.new("macc2", user)
          )
        end
        it "returns the specified sites' hosts" do
          expect(described_class.host("macc1", "ictc2").apply(sites)).to contain_exactly(
            Sites::Host.new("macc1", user),
            Sites::Host.new("ictc2", user)
          )
        end
      end
    end
  end
end
