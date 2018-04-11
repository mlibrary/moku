# frozen_string_literal: true

require "fauxpaas/release_signature"
require "time"

module Fauxpaas

  # A representation of a release within a log that includes additional
  # metadata.
  class LoggedRelease

    class << self
      def from_hash(hash)
        new(
          hash[:user],
          Time.strptime(hash[:time], time_format),
          ReleaseSignature.from_hash(hash[:signature])
        )
      end

      def time_format
        "%FT%T"
      end
    end

    attr_reader :signature

    # @param user [#to_s]
    # @param time [Time]
    # @param signature [ReleaseSignature]
    def initialize(user, time, signature)
      @user = user
      @time = time
      @signature = signature
    end

    def to_s
      "#{formatted_time}: #{user} #{archive_s(signature.source)} " \
        "w/ #{archive_s(signature.deploy)}\n" \
        "  #{archive_s(signature.unshared)}\n" \
        "  #{archive_s(signature.shared)}"
    end

    def to_hash
      {
        user:      user,
        time:      formatted_time,
        signature: signature.to_hash
      }
    end

    private

    attr_reader :user, :time

    def archive_s(archives)
      [archives].flatten.map(&:commitish).join(" ")
    end

    def formatted_time
      time.strftime(LoggedRelease.time_format)
    end

  end
end
