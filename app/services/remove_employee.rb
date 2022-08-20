# frozen_string_literal: true

module TrackIt
  # Remove an employee in a department
  class RemoveEmployee
    # Error for unauthorized request
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that user'
      end
    end

    def self.call(account:, department:, employee_email:)
      employee = Account.first(email: employee_email)
      policy = EmployeeRequestPolicy.new(department, account, employee)

      raise ForbiddenError unless policy.can_remove?

      department.remove_employee(employee)
      employee
    end
  end
end
