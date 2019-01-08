# frozen_string_literal: true

require "moku/upload"

module Moku

  # A local upload for the purposes of testing. It prepends the deploy_root
  # and the hostname-as-a-directory to the destination.
  class LocalUpload < Upload

    def full_dest
      host_path/dest
    end

    private

    def host_path
      Moku.deploy_root/(host.hostname)
    end

  end
end
