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
      account_is_owner?
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
        can_remove_employees: can_remove_employees?
      }
    end

    private

    def account_is_owner?
      @department.organization.owner == @account
    end

    def account_is_employee?
      is_there = false
      @account.teams.each do |team|
        if team.id == @department.id
          is_there = true
          break
        end
      end
      is_there
    end

    def account_is_admin?
      dep = nil
      @account.teams.each do |team|
        if team.id == @department.id
          dep = team
          break
        end
      end
      dep.values[:role_id] == 1 if dep
    end
  end
end
