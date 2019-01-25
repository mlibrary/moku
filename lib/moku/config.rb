# frozen_string_literal: true

require "canister"
require "ettin"
require "logger"
require "pathname"

module Moku

  # This sets basic configuration for the top-level Moku object.
  # Primarily, separating this out of moku.rb allows for dependents
  # to get what they need without also bringing in the entire project,
  # mostly for testing.
  module Config
    attr_writer :config, :env

    def respond_to_missing?(method_name, include_private = false)
      config.respond_to?(method_name) || super
    end

    def method_missing(method, *args, &block)
      if config.respond_to?(method)
        config.send(method, *args, &block)
      else
        super
      end
    end

    def config
      @config ||= Canister.new.tap do |canister|
        settings.each {|k, v| canister.register(k) { v } }
      end
    end

    def load_settings!(overrides = {})
      @settings = Ettin.for(Ettin.settings_files(root/"config", env)).merge!(overrides)
    end

    def settings
      load_settings! unless @settings
      @settings
    end

    def root
      @root ||= Pathname.new(__dir__).parent.parent
    end

    def reset!
      @settings = nil
      @config = nil
    end

    def env
      @env ||= ENV["MOKU_ENV"] || ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
    end

  end
end

Moku.extend(Moku::Config)
