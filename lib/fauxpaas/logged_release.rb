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

    def to_brief_hash
      {
        time:     formatted_time,
        user:     user,
        source:   signature.source.commitish,
        deploy:   signature.deploy.commitish,
        unshared: signature.unshared.commitish,
        shared:   signature.shared.commitish
      }
    end

    def to_s
      "#{formatted_time}: #{user} #{signature.source.commitish} " \
        "w/ #{signature.deploy.commitish}\n" \
        "  #{signature.unshared.commitish}\n" \
        "  #{signature.shared.commitish}"
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

    def formatted_time
      time.strftime(self.class.time_format)
    end

  end
end
