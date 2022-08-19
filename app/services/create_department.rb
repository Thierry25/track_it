# frozen_string_literal: true

module TrackIt
  # Service object to create a department within an organization
  class CreateDepartment
    def self.call(organization_id:, department_data:)
      Organization.first(id: organization_id).add_department(department_data)
    end
  end
end
