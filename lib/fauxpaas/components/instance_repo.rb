# frozen_string_literal: true

require "fauxpaas/file_instance_repo"

module Fauxpaas
  class << self
    def instance_repo
      @instance_repo ||= FileInstanceRepo.new(instance_root)
    end

    attr_writer :instance_repo
  end
end
