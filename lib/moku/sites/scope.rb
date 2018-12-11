# frozen_string_literal: true

module Moku
  class Sites

    # Scopes are used to create an a list of hosts from a Sites
    # object.
    class Scope

      def self.all
        new(proc {|sites| sites.hosts })
      end

      def self.each_site
        new(proc {|sites| sites.primaries })
      end

      def self.once
        new(proc {|sites| [sites.primary] })
      end

      def self.site(*site_names)
        new(proc {|sites| sites.site(*site_names).hosts })
      end

      def self.host(*hostnames)
        new(proc {|sites| sites.host(*hostnames) })
      end

      def initialize(callable)
        @callable = callable
      end

      def apply(sites)
        callable.call(sites)
      end

      private

      attr_reader :callable

    end
  end
end
