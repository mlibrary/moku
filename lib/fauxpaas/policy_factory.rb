require "fauxpaas/policy"

module Fauxpaas

  # Creates policies from the loaded role information
  # @param all [Hash<String, Array>] Hash of role:usernames pairs.
  # @param instances [Hash<String, Hash<String,Array>>] The keys of the
  #   top level hash are the instance names, each of which has as its
  #   value a hash of role:usernames pairs.
  class PolicyFactory
    def initialize(all: {}, instances: {}, policy_type: Policy)
      @all = all
      @instances = instances
      @policy_type = policy_type
    end

    def for(user_name, instance_name)
      raise ArgumentError, "missing user_name" unless user_name
      raise ArgumentError, "missing instance_name" unless instance_name
      policy_type.new(roles(user_name, instance_name))
    end

    private

    def roles(user_name, instance_name)
      all.merge(instances.fetch(instance_name, {})) do |key, oldval, newval|
        oldval + newval
      end
        .select{|role, users| users.include?(user_name)}
        .keys
        .map(&:to_sym)
    end

    attr_reader :all, :instances, :policy_type
  end
end

