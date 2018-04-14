require "core_extensions/hash/deep_transform"

module Fauxpaas
  module Keys
    unless method_defined?(:stringify_keys)
      def stringify_keys
        deep_transform_keys{|key| key.to_s }
      end
    end

    unless method_defined?(:stringify_keys!)
      def stringify_keys!
        deep_transform_keys!{|key| key.to_s }
      end
    end

    unless method_defined?(:symbolize_keys)
      def symbolize_keys
        deep_transform_keys{|key| key.to_sym rescue key }
      end
    end

    unless method_defined?(:symbolize_keys!)
      def symbolize_keys!
        deep_transform_keys!{|key| key.to_sym rescue key }
      end
    end

  end
end

unless {}.respond_to?(:stringify_keys)
  Hash.include Fauxpaas::Keys
end
