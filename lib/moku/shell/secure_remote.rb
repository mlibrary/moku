# frozen_string_literal: true

require "base64"

module Moku
  module Shell

    # A shell that uses ssh
    class SecureRemote

      def initialize(system_shell)
        @system_shell = system_shell
      end

      def ssh_options
        @ssh_options ||= [
          "-o BatchMode=yes",
          "-o ConnectTimeout=3",
          "-o ChallengeResponseAuthentication=no",
          "-o PasswordAuthentication=no",
          "-o LogLevel=ERROR",
          "-a",
          "-i #{ENV["HOME"]}/.ssh/id_rsa-moku"
        ].freeze
      end

      def run(host:, command:, user: Moku.user)
        # This is a little gnarly because we need the local bash to pass any
        # variable expressions through. That can either be done by escaping
        # individual special characters or single quoting the whole command.
        # Quoting the whole remote command is preferable, to avoid missing or
        # mangling anything, but because it used as a local argument, it must
        # be single quoted again. Using the heredoc allows us to use both types
        # of quotes in the Ruby string without a bunch of \'s.
        #
        # If the ultimate remote command should be: echo $PATH
        # The local command should be: ssh ... bash -l -c "'"'echo $PATH"'"'
        # So the command passed to ssh is: bash -l -c 'echo $PATH'

        encoded = Base64.strict_encode64(command)
        message = <<~CMD
          ssh #{ssh_options.join(" ")} #{user}@#{host} bash -l -c "'"'#{command}'"'"
        CMD
        real_command = <<~CMD
          ssh #{ssh_options.join(" ")} #{user}@#{host} bash -l -c "'"'eval "$(echo #{encoded} | base64 -d)"'"'"
        CMD
        system_shell.run(real_command, message)
      end

      private

      attr_reader :system_shell

    end

  end
end
