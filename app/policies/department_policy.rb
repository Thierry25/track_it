# frozen_string_literal: true

module TrackIt
  # Policy to determine access to department details
  class DepartmentPolicy
    def initialize(account, department)
      @account = account
      @department = department
    end

    def can_view?
      account_is_owner? || account_is_employee?
    end

    def can_edit?
      account_is_owner? || account_is_admin?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_employee?
    end

    def can_add_projects?
      account_is_owner? || account_is_admin?
    end

    def can_remove_projects?
      account_is_owner? || account_is_admin?
    end

    def can_add_employees?
      account_is_owner? || account_is_admin?
    end

    def can_remove_employees?
      account_is_owner? || account_is_admin?
    end

    def can_add_admin?
      account_is_owner? && admin_count?
    end

    def can_remove_admin?
      account_is_owner?
    end

    def can_be_employee?
      !(account_is_owner? || account_is_employee?)
    end

    def can_be_admin?
      # !(account_is_owner? || role? == 2 || role? == 3 || role? == 4)
      !(account_is_owner? || account_is_manager? || account_is_soft_dev? || account_is_tester?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_projects: can_add_projects?,
        can_remove_projects: can_remove_projects?,
        can_add_employees: can_add_employees?,
        can_remove_employees: can_remove_employees?,
        can_be_employee: can_be_employee?,
        can_add_admin: can_add_admin?,
        can_remove_admin: can_remove_admin?,
        can_be_admin: can_be_admin?
      }
    end

    private

    def account_is_owner?
      @department.organization.owner == @account
    end

    def admin_count?
      @department.admins.count.zero?
    end

    def account_is_employee?
      is_there = false
      @account&.teams&.each do |team|
        if team.id == @department.id
          is_there = true
          break
        end
      end
      is_there
    end

    def account_is_admin?
      @department.admins&.map(&:id)&.include? @account.id
    end

    def account_is_manager?
      @department.project_managers&.map(&:id)&.include? @account.id
    end

    def account_is_soft_dev?
      @account.developing_at&.map(&:id)&.include? @department.id
      # @department.soft_devs&.map(&:id)&.include? @account.id
    end

    def account_is_tester?
      @account.testing_at&.map(&:id)&.include? @department.id
      # @department.testers&.map(&:id)&.include? @account.id
    end
  end
end
