# frozen_string_literal: true

require "fauxpaas/version"
require "fauxpaas/cli"
require "fauxpaas/open3_capture"
require "fauxpaas/invoker"

require "logger"
require "pathname"
require "canister"
require "ettin"

# Fake Platform As A Service
module Fauxpaas
  class << self
    attr_reader :config, :env, :settings
    attr_writer :config, :env

    def method_missing(method, *args, &block)
      if config.respond_to?(method)
        config.send(method, *args, &block)
      else
        super(method, *args, &block)
      end
    end

    def root
      @root ||= Pathname.new(__FILE__).dirname.parent
    end

    def env
      @env ||= ENV["FAUXPAAS_ENV"] || ENV["RAILS_ENV"] || "development"
    end

    def reset!
      @settings = nil
      @loaded = false
      @config = nil
    end

    def load_settings!(hash = {})
      @settings = Ettin.for(Ettin.settings_files(root/"config", env))
      @settings.merge!(hash)
    end

    def initialize!
      load_settings! unless @settings
      @config ||= Canister.new.tap do |container|
        container.register(:logger) { Logger.new(STDOUT, level: :info) }
        container.register(:logger) do
          if settings.verbose
            Logger.new(STDOUT, level: :debug)
          else
            Logger.new(STDOUT, level: :info)
          end
        end
        container.register(:system_runner) { Open3Capture.new }
        container.register(:invoker) { Fauxpaas::Invoker.new }
      end
    end

  end
end

