# frozen_string_literal: true

module TrackIt
  # Service object to determine if an account has access to see department details
  class GetDepartmentQuery
    # Error account cannot get access to department
    class ForbiddenError < StandardError
      def message
        'You are not allowed to get access to this department'
      end
    end

    # Error for dpeartment not found
    class NotFoundError < StandardError
      def message
        'We could not find this department'
      end
    end

    def self.call(requestor:, department:)
      raise NotFoundError unless department

      policy = DepartmentPolicy.new(requestor, department)
      raise ForbiddenError unless policy.can_view?

      department.full_details.merge(policies: policy.summary)
    end
  end
end
