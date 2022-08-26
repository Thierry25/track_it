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

      remove_employee(department, employee)
      employee
    end

    def self.remove_employee(department, employee)
      department.employees.reject do |emp|
        emp.id == employee.id
      end
    end

    private_class_method :remove_employee
  end
end
