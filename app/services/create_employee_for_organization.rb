# frozen_string_literal: true

module TrackIt
  # Create an employee to an existing organization
  class CreateEmployeeForOrganization
    # Error for owner cannot be employee
    class OwnerNotEmployeeError < StandardError
      def message = 'Owner cannot be employee of organization'
    end

    def self.call(organization_id:, account_data:)
      organization = Organization.first(id: organization_id)
      raise(OwnerNotEmployeeError) if organization.owner.email == account_data['email']

      organization.add_employee(account_data)
    end
  end
end
