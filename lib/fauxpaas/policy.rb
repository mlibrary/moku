# frozen_string_literal: true

module Fauxpaas

  # The policy is responsible for deciding whether or not a
  # user can perform an action.
  class Policy
    def self.all_roles
      IMPLIED_BY.keys
    end

    def self.for(roles)
      new(roles)
    end

    def initialize(roles)
      @roles = roles
    end

    def authorized?(action)
      role?(ACTION_TO_ROLE.fetch(action, :none))
    end

    private

    attr_reader :roles

    # The key is implied by each of the roles in the value
    IMPLIED_BY = {
      admin:   [:admin].freeze,
      deploy:  [:admin, :deploy].freeze,
      restart: [:admin, :deploy, :restart].freeze,
      read:    [:admin, :deploy, :edit, :read].freeze,
      edit:    [:admin, :edit].freeze
    }.freeze

    ACTION_TO_ROLE = {
      deploy:              :deploy,
      read_default_branch: :read,
      set_default_branch:  :edit,
      rollback:            :deploy,
      caches:              :read,
      releases:            :read,
      restart:             :restart,
      exec:                :deploy,
      syslog_view:         :read,
      syslog_grep:         :read,
      syslog_follow:       :read
    }.freeze

    def role?(role)
      !(roles & IMPLIED_BY.fetch(role, [])).empty?
    end

  end
end
