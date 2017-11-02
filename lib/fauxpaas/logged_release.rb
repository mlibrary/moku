module Fauxpaas
  class LoggedRelease
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

    def formatted_time
      time.strftime("%FT%T")
    end

  end
end
