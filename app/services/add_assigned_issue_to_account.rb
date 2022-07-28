# frozen_string_literal: true

module TrackIt
  # Service Object to assign a given issue to an account
  class AssignIssueToAccount
    # Error for account that cannot be assigned any issues
    class AccountNotAssigneeError < StandardError
      def message = 'This account cannot be assigned an issue'
    end

    def self.call(issue_id:, email:, department_id:)
      assignee = Account.first(email:)
      issue = Issue.first(id: issue_id)
      department = Department.first(id: department_id)

      raise(AccountNotAssigneeError) if owner?(assignee,
                                               department) || !employee?(assignee,
                                                                         department) || role?(
                                                                           assignee, department
                                                                         ) != 3

      issue.add_assignee(assignee)
    end

    def self.owner?(assignee, department)
      return true if department.organization.owner.id == assignee.id
    end

    def self.employee?(assignee, department)
      is_there = false
      assignee.teams.each do |team|
        if team.id == department.id
          is_there = true
          break
        end
      end
      is_there
    end

    def self.role?(assignee, department)
      user = nil
      department.employees.each do |employee|
        if employee.id == assignee.id
          user = employee
          break
        end
      end
      user.values[:role_id] if user
    end

    private_class_method :owner?, :employee?, :role?
  end
end
