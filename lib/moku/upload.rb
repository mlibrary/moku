# frozen_string_literal: true

module Moku

  # An upload from a source path to a destination path. This is the intent to
  # upload reified.
  class Upload

    # @param source [Pathname,String]
    # @param host [Sites::Host]
    # @param dest [Pathname,String] If dest contains a colon, the left side
    #   will be treated as the hostname.
    def initialize(source, host, dest)
      @source = source.to_s
      @host = host
      @dest = dest
    end

    # Perform this upload with the given runner.
    # @return [Status] Return type is whatever the runner returns, likely
    #   a Status instance.
    def with(runner)
      runner.run(to_command)
    end

    # This upload as a shell command
    # @return [String]
    def to_command
      "rsync -vrlpz #{source}/. #{full_dest}/"
    end

    def full_dest
      "#{host.user}@#{host.hostname}:#{dest}"
    end

    private

    attr_reader :source, :host, :dest

  end

end
