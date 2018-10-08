require "fauxpaas/sites"

module Fauxpaas
  RSpec.describe Sites do
    let(:hash) do
      {
        "macc" => [
          "macc1",
          { hostname: "macc2" }
         ],
        "ictc" => [
          { hostname: "ictc1" },
          "ictc2"
         ]
      }
    end
    let(:sites) { described_class.new(hash) }

    it "#hosts returns all hosts" do
      expect(sites.hosts).to contain_exactly(
        Sites::Host.new("macc1"),
        Sites::Host.new("macc2"),
        Sites::Host.new("ictc1"),
        Sites::Host.new("ictc2")
      )
    end

    it "#primaries returns the first host from each site" do
      expect(sites.primaries).to contain_exactly(
        Sites::Host.new("macc1"),
        Sites::Host.new("ictc1")
      )
    end

    it "#primary returns the first host only" do
      expect(sites.primary).to eql(Sites::Host.new("macc1"))
    end


  end
end
