module Fauxpaas
  class Container
    def register(key, &block)
      registry[key.to_sym] = block
    end

    def method_missing(method, *args, &block)
      if respond_to?(method)
        lookup(method)
      else
        super(method, *args, block)
      end
    end

    def respond_to?(method)
      super || registry.has_key?(method)
    end

    def lookup(key)
      resolved[key.to_sym] ||= registry[key.to_sym].call(self)
    end

    def reset!(key)
      resolved.delete(key.to_sym)
    end

    # Resets all resolved variables
    def reset_all!
      @resolved = {}
    end

    private

    def registry
      @registry ||= {}
    end

    def resolved
      @resolved ||= {}
    end
  end
end

