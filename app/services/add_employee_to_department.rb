# frozen_string_literal: true

module TrackIt
  # Service Object to add employee to a department
  class AddEmployeeToDepartment
    # Error for owner cannot be employee in department
    class OwnerNotEmployeeError < StandardError
      def message = 'Owner cannot be employee in a department'
    end

    def self.call(department_id:, email:)
      employee = Account.first(email:)
      department = Department.first(id: department_id)
      raise(OwnerNotEmployeeError) if department.organization.owner.id == employee.id

      department.add_employee(employee)
    end
  end
end
