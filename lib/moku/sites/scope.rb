# frozen_string_literal: true

module Moku
  class Sites

    # Scopes are used to create a list of hosts from a Sites object.
    class Scope

      def self.all
        new(:all, proc {|sites| sites.hosts })
      end

      def self.each_site
        new(:each_site, proc {|sites| sites.primaries })
      end

      def self.once
        new(:once, proc {|sites| [sites.primary] })
      end

      def self.site(*site_names)
        new("site:#{site_names}", proc {|sites| sites.site(*site_names).hosts })
      end

      def self.host(*hostnames)
        new("host:#{hostnames}", proc {|sites| sites.host(*hostnames) })
      end

      def initialize(identifier, callable)
        @identifier = identifier
        @callable = callable
      end

      attr_reader :identifier

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
