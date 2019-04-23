# frozen_string_literal: true

require "moku"
require "moku/command/command"
require "moku/pipeline/rollback"

module Moku

  module Command
    # Rollback to a cached release
    class Rollback < Command
      def initialize(instance_name:, user:, cache_id: nil)
        super(instance_name: instance_name, user: user)
        @cache_id = cache_id
      end

      def action
        :rollback
      end

      def call
        Pipeline::Rollback.new(
          cache: cache,
          instance: instance,
          user: user
        ).call
      end

      private
      attr_reader :cache_id

      def cache
        @cache ||= if cache_id
          instance.caches.find {|cache| cache.id == cache_id }
        else
          instance.caches.first
        end
      end

    end

  end
end
