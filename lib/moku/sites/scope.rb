# frozen_string_literal: true

module Moku
  class Sites

    # Scopes are used to create a list of hosts from a Sites object.
    class Scope

      # All of the hosts
      def self.all
        new(:all, proc {|sites| sites.hosts })
      end

      # Just the primary host from each site
      def self.each_site
        new(:each_site, proc {|sites| sites.primaries })
      end

      # Exactly one primary host, chosen randomly
      def self.once
        new(:once, proc {|sites| [sites.primary] })
      end

      # The union of all  hosts as the given sites
      def self.site(*site_names)
        new("site:#{site_names}", proc {|sites| sites.site(*site_names).hosts })
      end

      # The listed hosts, regardless of site
      def self.host(*hostnames)
        new("host:#{hostnames}", proc {|sites| sites.host(*hostnames) })
      end

      def initialize(identifier, callable)
        @identifier = identifier
        @callable = callable
      end

      attr_reader :identifier

      # Apply this scope to the sites instance
      def apply(sites)
        callable.call(sites)
      end

      def eql?(other)
        identifier == other.identifier
      end
      alias_method :==, :eql?

      private

      attr_reader :callable

    end
  end
end
