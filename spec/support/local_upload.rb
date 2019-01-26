# frozen_string_literal: true

require "moku/upload"

module Moku

  # A local upload for the purposes of testing. It prepends the deploy_root
  # and the hostname-as-a-directory to the destination.
  class LocalUpload < Upload

    def full_dest
      # workaround for ruby bug #15564
      Pathname.new(File.join(Moku.deploy_root/host.hostname, dest))
    end

  end
end
