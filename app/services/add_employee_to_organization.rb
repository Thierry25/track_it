# frozen_string_literal: true

module TrackIt
  # Add an employee to an exisitng organization
  class AddEmployeeToOrganization
    # Error for owner cannot be employee
    class OwnerNotEmployeeError < StandardError
      def message = 'Owner cannot be employee of organization'
    end

    def self.call(organization_id:, email:)
      employee = Account.first(email:)
      organization = Organization.first(id: organization_id)
      raise(OwnerNotEmployeeError) if organization.owner.id == employee.id

      organization.add_employee(employee)
    end
  end
end
