# frozen_string_literal: true

require "core_extensions/hash/deep_transform"

module Fauxpaas

  # Behavior from ActiveSupport's hash/keys
  module Keys
    unless method_defined?(:stringify_keys)
      def stringify_keys
        deep_transform_keys(&:to_s)
      end
    end

    unless method_defined?(:stringify_keys!)
      def stringify_keys!
        deep_transform_keys!(&:to_s)
      end
    end

    unless method_defined?(:symbolize_keys)
      def symbolize_keys
        deep_transform_keys do |key|
          begin
            key.to_sym
          rescue StandardError
            key
          end
        end
      end
    end

    unless method_defined?(:symbolize_keys!)
      def symbolize_keys!
        deep_transform_keys! do |key|
          begin
            key.to_sym
          rescue StandardError
            key
          end
        end
      end
    end

  end
end

unless {}.respond_to?(:stringify_keys)
  Hash.include Fauxpaas::Keys
end
