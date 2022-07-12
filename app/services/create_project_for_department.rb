# frozen_string_literal: true

module TrackIt
  # Service object to create a project within a department
  class CreateProjectForDepartment
    def self.call(department_id:, project_data:)
      Department.find(id: department_id).add_project(project_data)
    end
  end
end
