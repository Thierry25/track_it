# frozen_string_literal: true

module TrackIt
  # Policy to determine access to issue's details
  class IssuePolicy
    def initialize(account, issue)
      @account = account
      @issue = issue
      @department = @issue.projects&.first&.department
    end

    def can_view?
      self_request? || account_is_owner? || account_is_manager? || account_is_admin? || account_is_assignee?
    end

    # ALLOW THE USER TO DELETE ITS OWN SUBMITTED ISSUE
    def can_rescind?
      self_request?
    end

    def can_assign_issues?
      account_is_manager? || account_is_admin?
    end

    def can_remove_assignment?
      account_is_manager? || account_is_admin?
    end

    def can_update_issues?
      account_is_manager? || account_is_admin? || account_is_assignee?
    end

    def can_add_comments?
      account_is_manager? || account_is_admin? || account_is_assignee?
    end

    def can_be_assigned_issue?
      !(account_is_manager? || account_is_admin? || account_is_tester?) && account_is_collaborator?
    end

    def summary
      {
        can_view: can_view?,
        can_assign: can_assign_issues?,
        can_update: can_update_issues?,
        can_rescind: can_rescind?,
        can_add_comments: can_add_comments?,
        can_remove_assignment: can_remove_assignment?,
        can_be_assigned_issue: can_be_assigned_issue?
      }
    end

    private

    def self_request?
      @issue.submitter == @account
    end

    def account_is_owner?
      @department&.organization&.owner == @account
    end

    def account_is_manager?
      @issue.projects&.first&.managers&.include? @account
    end

    def account_is_collaborator?
      @issue.projects&.first&.collaborators&.include? @account
    end

    def account_is_assignee?
      @issue.assignees&.include? @account
    end

    def account_is_admin?
      @department&.admins&.map(&:id)&.include? @account.id
    end

    def account_is_tester?
      @department&.testers&.map(&:id)&.include? @account.id
    end
  end
end
