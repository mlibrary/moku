# frozen_string_literal: true

require "fauxpaas/file_instance_repo"
require "fauxpaas/components/paths"
require "fauxpaas/components/filesystem"

module Fauxpaas
  class << self
    def instance_repo
      @instance_repo ||= FileInstanceRepo.new(instance_root, releases_root, filesystem)
    end

    attr_writer :instance_repo
  end
end
