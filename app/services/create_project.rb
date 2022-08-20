# frozen_string_literal: true

module TrackIt
  # Service object to create a project within a department
  class CreateProject
    # Error for account that cannot create new project
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create new project'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'You cannot create a new project with the following attributes'
      end
    end

    def self.call(account:, department:, project_data:)
      policy = DepartmentPolicy.new(department, account)
      raise ForbiddenError unless policy.can_add_projects?

      add_project(department, project_data)
    end

    def self.add_project(department, project_data)
      department.add_project(project_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
