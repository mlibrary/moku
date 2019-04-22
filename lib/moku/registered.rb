module Moku

  module Registered
    def for(target)
      registry.find {|candidate| candidate.handles?(target) }
        .new(target)
    end

    def registry
      @@registry ||= [] # rubocop:disable Style/ClassVars
    end

    def register(candidate)
      registry.unshift(candidate)
    end

    def handles?(_target)
      true
    end
  end

end
