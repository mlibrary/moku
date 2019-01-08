# frozen_string_literal: true

require "core_extensions/hash/keys"
module Moku

  # A mapping of hosts within zero or more sites.
  class Sites

    Host = Struct.new(:hostname)

    # Build an instance from a path to a file
    def self.from_file(path)
      new(YAML.safe_load(File.read(path)))
    end

    def initialize(sites)
      @sites = sites.symbolize_keys
        .transform_values do |hosts|
          hosts.map {|host| normalize_host(host) }
        end
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

    def normalize_host(host)
      case host
      when String
        Host.new(host)
      when Hash
        Host.new(host[:hostname])
      when Host
        host
      else
        raise "Could not understand #{host.inspect}"
      end
    end

  end
end
