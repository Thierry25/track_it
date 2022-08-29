# frozen_string_literal: true

module TrackIt
  # Service Object to remove a previously assigned issue
  class RemoveAssignedIssue
    # Error for account that cannot remove assigned issue
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove this assigned issue from this account'
      end
    end

    def self.call(account:, issue:, assignee_email:)
      assignee = Account.first(email: assignee_email)
      policy = AssignIssueRequestPolicy.new(issue, account, assignee)
      raise ForbiddenError unless policy.can_remove_assignment?

      issue.remove_assignee(assignee)
      assignee
    end
  end
end
