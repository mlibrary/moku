require 'digest/sha1'

module Fauxpaas
  # Describes a single deployment for later logging
  # * TIMESTAMP: When deployment process completed
  # * USER: The user who initiated it
  # * SRC: SHA of the source code deployed
  # * CONFIG: SHA of the developer configuration deployed
  # * DEPLOY: SHA of the deployment configuration used
  class Deployment
    attr_reader :user, :timestamp, :src, :dev_config, :deploy_config

    def initialize(src,timestamp: Time.now, user: :FIXME,
                   dev_config: '(none)', deploy_config: '(none)')
      @user = user
      @timestamp = timestamp
      @src = src
      @dev_config = dev_config
      @deploy_config = deploy_config
    end

    def to_hash
      { 'src' => src,
        'user' => user,
        'config' => dev_config,
        'deploy' => deploy_config,
        'timestamp' => timestamp.to_s }
    end

    def to_s
      "#{timestamp}: #{user} deployed #{src} #{dev_config} " +
      "with #{deploy_config}"
    end
  end
end
