# frozen_string_literal: true

module TrackIt
  # Service Object that determines if an account can access an issue details
  class GetIssueQuery
    # Error when accounts does not have authorization to access resource
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access this issue details'
      end
    end

    # Error when resource does not exist
    class NotFoundError < StandardError
      def message
        'We could not find this issue'
      end
    end

    def self.call(requestor:, issue:)
      raise NotFoundError unless issue

      policy = IssuePolicy.new(requestor, issue)
      raise ForbiddenError unless policy.can_view?

      issue.full_details.merge(policies: policy.summary)
    end
  end
end
