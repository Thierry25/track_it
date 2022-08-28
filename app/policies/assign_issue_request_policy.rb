# frozen_string_literal: true

module TrackIt
  # Policy to determine if an account can assign an issue to another account
  class AssignIssueRequestPolicy
    def initialize(issue, requestor_account, target_account)
      @issue = issue
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = IssuePolicy.new(requestor_account, issue)
      @target = IssuePolicy.new(target_account, issue)
    end

    def can_assign?
      @requestor.can_assign_issues? && @target.can_be_assigned_issue?
    end

    def can_remove_assignment?
      @requestor.can_remove_assignment? && target_is_assignee?
    end

    private

    def target_is_assignee?
      @issue&.assignees&.include?(@target_account)
    end
  end
end
