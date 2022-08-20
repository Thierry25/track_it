# frozen_string_literal: true

module TrackIt
  # Service object to determine if account have access to project details
  class GetProjectQuery
    # Error for account that does not have authorization
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access this project details'
      end
    end

    # Error for resource not found
    class NotFoundError < StandardError
      def message
        'We could not find this project'
      end
    end

    def self.call(requestor:, project:)
      raise NotFoundError unless project

      policy = ProjectPolicy.new(requestor, project)
      raise ForbiddenError unless policy.can_view?

      project.full_details.merge(policies: policy.summary)
    end
  end
end
