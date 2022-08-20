# frozen_string_literal: true

module TrackIt
  # Service object to create a department within an organization
  class CreateDepartment
    # Error for account without the necessary authorization
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create a new department'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'You cannot create a new department with the following attributees'
      end
    end

    def self.call(account:, organization:, department_data:)
      policy = OrganizationPolicy.new(account, organization)
      raise ForbiddenError unless policy.can_add_departments?

      add_department(organization, department_data)
    end

    def self.add_department(organization, department_data)
      organization.add_department(department_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end

    private_class_method :add_department
  end
end
