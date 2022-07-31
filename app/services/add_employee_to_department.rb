# frozen_string_literal: true

module TrackIt
  # Service Object to add employee to a department
  class AddEmployeeToDepartment
    # Error for owner cannot be employee in department
    class OwnerNotEmployeeError < StandardError
      def message = 'Owner cannot be employee in a department'
    end

    def self.call(department_id:, email:, role_id:)
      employee = Account.first(email:)
      department = Department.first(id: department_id)
      raise(OwnerNotEmployeeError) if department.organization.owner.id == employee.id

      TrackIt::Api.DB[:accounts_departments]
                  .insert(department_id:, employee_id: employee.id, role_id:)
    end
  end
end
