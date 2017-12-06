# frozen_string_literal: true

require "fauxpaas/components/paths"

# Fake Platform As A Service
module Fauxpaas

  class << self
    def split_token
      @split_token ||= File.read(root + ".split_token").chomp.freeze
    end
  end

end
