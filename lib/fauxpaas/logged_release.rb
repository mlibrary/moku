require "time"

module Fauxpaas
  class LoggedRelease
    def self.from_hash(hash)
      new(
        hash[:user],
        Time.strptime(hash[:time], time_format),
        ReleaseSignature.from_hash(hash[:signature])
      )
    end

    def initialize(user, time, signature)
      @user = user
      @time = time
      @signature = signature
    end

    def to_s
      "#{formatted_time}: #{user} #{signature.source.reference} " \
        "#{signature.infrastructure.reference} " \
        "w/ #{signature.deploy.reference}"
    end

    def to_hash
      {
        user: user,
        time: formatted_time,
        signature: signature.to_hash
      }
    end

    private
    attr_reader :user, :time, :signature

    def self.time_format
      "%FT%T"
    end

    def formatted_time
      time.strftime(LoggedRelease.time_format)
    end

  end
end
