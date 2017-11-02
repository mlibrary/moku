module Fauxpaas
  class GitReference
    def initialize(url, reference)
      @url = url
      @reference = reference
    end

    attr_reader :url, :reference

    def to_hash
      {
        url: url,
        reference: reference
      }
    end
  end
end
