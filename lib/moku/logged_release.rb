# frozen_string_literal: true

require "moku/release_signature"
require "time"

module Moku

  # A representation of a release within a log that includes additional
  # metadata.
  class LoggedRelease

    class << self
      def from_hash(hash)
        time = Time.strptime(hash[:time], time_format)
        signature = ReleaseSignature.from_hash(hash[:signature])
        new(
          id: hash[:id] || (time+0.001).strftime(Moku.release_time_format),
          user: hash[:user],
          time: time,
          version: hash[:version] || signature.source.commitish,
          signature: signature
        )
      end

      def time_format
        "%FT%T"
      end
    end

    attr_reader :id, :signature

    # @param id [String]
    # @param signature [ReleaseSignature]
    # @param time [Time]
    # @param user [String]
    # @param version [String]
    def initialize(id:, signature:, time:, user:, version:)
      @id = id
      @signature = signature
      @time = time
      @user = user
      @version = version
    end

    def to_brief_hash
      {
        id:       id,
        version:  version,
        time:     formatted_time,
        user:     user,
        source:   source,
        deploy:   deploy,
        dev:      dev,
        infrastructure:   infrastructure
      }
    end

    def to_s
      "#{formatted_time}: #{user} #{id} #{version} w/ #{deploy}\n" \
        "  #{source}\n" \
        "  #{dev}\n" \
        "  #{infrastructure}"
    end

    def to_hash
      {
        id:        id,
        version:   version,
        user:      user,
        time:      formatted_time,
        signature: signature.to_hash
      }
    end

    private

    attr_reader :time, :user, :version

    def deploy
      signature.deploy.commitish
    end

    def source
      signature.source.commitish
    end

    def infrastructure
      signature.infrastructure.commitish
    end

    def dev
      signature.dev.commitish
    end

    def formatted_time
      time.strftime(self.class.time_format)
    end

  end
end
