# frozen_string_literal: true

module Fauxpaas
  module Shell

    # A shell that uses ssh
    class SecureRemote

      SSH_OPTIONS = [
        "-o BatchMode=yes",
        "-o ConnectTimeout=3",
        "-o ChallengeResponseAuthentication=no",
        "-o PasswordAuthentication=no",
        "-o UserKnownHostsFile=/dev/null",
        "-o StrictHostKeyChecking=no",
        "-a",
        "-i #{ENV["HOME"]}/.ssh/id_rsa-fauxpaas"
      ].freeze

      def initialize(system_shell)
        @system_shell = system_shell
      end

      def run(host:, command:, user: Fauxpaas.user)
        system_shell.run("ssh #{SSH_OPTIONS.join(" ")} #{user}@#{host} #{command}")
      end

      private

      attr_reader :system_shell

    end

  end
end
