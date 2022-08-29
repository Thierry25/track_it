# frozen_string_literal: true

module TrackIt
  # Service Object to assign a given issue to an account
  class AssignIssue
    # Error for account that cannot assign issue to another account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to assign this issue to this account'
      end
    end

    def self.call(account:, issue:, assignee_email:)
      assignee = Account.first(email: assignee_email)
      policy = AssignIssueRequestPolicy.new(issue, account, assignee)
      raise ForbiddenError unless policy.can_assign?

      issue.add_assignee(assignee)
      assignee
    end
  end
end
