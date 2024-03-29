# frozen_string_literal: true

module TrackIt
  # Service Object to add employee to a department
  class AddEmployee
    # Error for account can't add another account to department
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add that person as an employee'
      end
    end

    def self.call(account:, department_id:, employee_email:, role_id:)
      employee = Account.first(email: employee_email)
      department = Department.first(id: department_id)
      policy = EmployeeRequestPolicy.new(department, account, employee)
      # raise(OwnerNotEmployeeError) if department.organization.owner.id == employee.id
      raise ForbiddenError unless policy.can_add?

      TrackIt::Api.DB[:accounts_departments]
                  .insert(department_id:, employee_id: employee.id, role_id:)
      employee
    end
  end
end
