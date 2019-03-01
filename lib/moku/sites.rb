# frozen_string_literal: true

require "core_extensions/hash/keys"
module Moku

  # A mapping of hosts within zero or more sites.
  class Sites

    Host = Struct.new(:hostname, :user)

    class << self
      def for(object)
        case object
        when Pathname
          from_file(object)
        when String
          from_yaml(object)
        when Hash
          if object.key?("nodes") || object.key?(:nodes)
            from_reverse_hash(object)
          else
            from_hash(object)
          end
        else
          raise ArgumentError, object.inspect
        end
      end

      def from_file(path)
        from_yaml(File.read(path))
      end

      def from_yaml(yaml)
        from_hash(YAML.safe_load(yaml))
      end

      def from_reverse_hash(hash)
        h = hash.symbolize_keys

        sites = Hash.new {|h, k| h[k] = [] }
        h[:nodes].map(&:to_a)
          .flatten(1)
          .each {|host, site| sites[site] << host }

        from_hash({ user: h[:user] }.merge(sites))
      end

      def from_hash(hash)
        h = hash.symbolize_keys
        sites = h.reject {|k, _| k == :user }
          .transform_values do |hosts|
            hosts.map {|host| normalize_host(host, h[:user]) }
          end
        new(sites)
      end

      private

      def normalize_host(host, default_user)
        case host
        when String
          Host.new(host, default_user)
        when Hash
          Host.new(host[:hostname], host[:user] || default_user)
        when Host
          host
        else
          raise "Could not understand #{host.inspect}"
        end
      end
    end

    def initialize(sites)
      @sites = sites
    end

    # @return [Array<String>]
    def site_names
      sites.keys.map(&:to_s)
    end

    # All of the hosts in the sites
    # @return [Array<Sites::Host>]
    def hosts
      sites.values.flatten
    end

    # Only the hosts that are primary to each site
    # @return [Array<Sites::Host>]
    def primaries
      sites.values.map(&:first).flatten
    end

    # Exactly one host that serves as the primary across
    # sites.
    # @return [Sites::Host]
    def primary
      hosts.first
    end

    # A new instance that contains only the specified sites.
    # @return [Sites]
    def site(*site_names)
      self.class.new(
        sites.clone.keep_if do |site_name, _hosts|
          site_names.include? site_name.to_s
        end
      )
    end

    # The hosts that match the given hostname
    # @return [Array<Sites::Host>]
    def host(*hostnames)
      hosts.select do |host|
        hostnames.include? host.hostname
      end
    end

    def eql?(other)
      sites == other.send(:sites)
    end

    private

    attr_reader :sites

  end
end
