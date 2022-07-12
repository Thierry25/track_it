# frozen_string_literal: true

module TrackIt
  # Service Object to assign a given issue to an account
  class AssignIssueToAccount
    def self.call(issue_id:, email:)
      assignee = Account.first(email:)
      issue = Issue.first(id: issue_id)

      issue.add_assignee(assignee)
    end
  end
end
