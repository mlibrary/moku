# frozen_string_literal: true

require "fauxpaas/filesystem"

module Fauxpaas
  class << self
    def filesystem
      @filesystem ||= Filesystem.new
    end

    attr_writer :filesystem
  end
end
