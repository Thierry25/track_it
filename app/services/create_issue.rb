# frozen_string_literal: true

module TrackIt
  # Service object to create an issue for a submitter
  class CreateIssue
    # Error for account with no authorization
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create new issues you'
      end

      # Error for requests with illegal attributes
      class IllegalRequestError < StandardError
        def message
          'You cannot create issue with the following attributes'
        end
      end
    end

    def self.call(account:, project:, issue_data:)
      policy = ProjectPolicy.new(account, project)
      raise ForbiddenError unless policy.can_add_issues

      add_issue(account, project, issue_data)
    end

    def self.add_issue(account, project, issue_data)
      issue = account.add_submitted_issue(issue_data)
      project.add_issue(issue) if issue
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end

    private_class_method :add_issue
  end
end
