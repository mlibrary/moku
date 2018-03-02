module Fauxpaas

  # The policy is responsible for deciding whether or not a
  # user can perform an action.
  class Policy
    # The key is implied by each of the roles in the value
    IMPLIED_BY = {
      admin: [:admin].freeze,
      deploy: [:admin, :deploy].freeze,
      restart: [:admin, :deploy, :restart].freeze,
      read: [:admin, :deploy, :edit, :read].freeze,
      edit: [:admin, :edit].freeze
    }.freeze

    def self.all_roles
      IMPLIED_BY.keys
    end

    def initialize(roles)
      @roles = roles
    end

    def deploy?
      role?(:deploy)
    end

    def read_default_branch?
      read?
    end

    def set_default_branch?
      edit?
    end

    def rollback?
      deploy?
    end

    def caches?
      read?
    end

    def releases?
      read?
    end

    def restart?
      role?(:restart)
    end

    def syslog_view?
      read?
    end

    def syslog_grep?
      read?
    end

    def syslog_follow?
      read?
    end

    private
    attr_reader :roles

    def role?(role)
      !(roles & IMPLIED_BY[role]).empty?
    end

    def admin?
      role?(:admin)
    end

    def read?
      role?(:read)
    end

    def edit?
      role?(:edit)
    end

  end
end
