# frozen_string_literal: true

module TrackIt
  # Policy to determine if an account can add/remove another in a department
  class EmployeeRequestPolicy
    def initialize(department, requestor_account, target_account)
      @department = department
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = DepartmentPolicy.new(requestor_account, department)
      @target = DepartmentPolicy.new(target_account, department)
    end

    def can_add?
      @requestor.can_add_employees? && target_is_employee?
    end

    def can_remove?
      @requestor.can_remove_employees? && @target.can_leave?
    end

    private

    def target_is_employee?
      is_there = false
      @target_account.teams.each do |team|
        if team.id == @department.id
          is_there = true
          break
        end
      end
      is_there
    end
  end
end
