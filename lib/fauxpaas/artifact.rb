# frozen_string_literal: true

module Fauxpaas
  # A set of files on disk as they will be uploaded to an
  # application server. Pending work on AEIM-1361, AEIM-1362,
  # AEIM-1375, AEIM-1363, etc to fully expose the proper shape of this.
  class Artifact
    def initialize(path)
      @path = path
    end

    attr_reader :path
  end

end
