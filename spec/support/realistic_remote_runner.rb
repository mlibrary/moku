# frozen_string_literal: true

require "moku/shell/secure_remote"

module Moku

  # A version of SecureRemote that only connects to localhost, and modifies paths.
  class RealisticRemoteRunner < Shell::SecureRemote
    def ssh_options
      @ssh_options ||= super.reject {|opt| opt.include?("-i") }
    end

    def run(host:, command:, user: :unused) # rubocop:disable Lint/UnusedMethodArgument
      (Moku.deploy_root/host).mkpath
      Dir.chdir(Moku.deploy_root/host) do |dir|
        super(
          host: "localhost",
          command: command.gsub(/ \//, " #{dir}/"),
          user: ENV["USER"]
        )
      end
    end
  end

end
