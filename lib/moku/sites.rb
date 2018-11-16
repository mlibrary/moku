# frozen_string_literal: true

require "core_extensions/hash/keys"
module Moku

  # A mapping of hosts within zero or more sites.
  class Sites

    Host = Struct.new(:hostname)

    def self.from_file(path)
      new(YAML.safe_load(File.read(path)))
    end

    def initialize(sites)
      @sites = sites.symbolize_keys
        .transform_values do |hosts|
          hosts.map {|host| normalize_host(host) }
        end
    end

    def hosts
      sites.values.flatten
    end

    def primaries
      sites.values.map(&:first).flatten
    end

    def primary
      hosts.first
    end

    private

    attr_reader :sites

    def normalize_host(host)
      case host
      when String
        Host.new(host)
      when Hash
        Host.new(host[:hostname])
      else
        raise "Could not understand #{host.inspect}"
      end
    end

  end
end
