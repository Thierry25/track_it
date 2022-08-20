# frozen_string_literal: true

module TrackIt
  # Service object to create an comment related to an issue
  class CreateIssueComment
    # Error for not having the authorization to create an issue
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create an issue related to that comment'
      end   
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'You cannot create an comment with these attributes'
      end
    end

    def self.call(account:, issue:, comment_data:)
      policy = IssuePolicy.new(account, issue)
      raise ForbiddenError unless policy.can_add_comments?

      add_comment(account, issue, comment_data)
    end

    def self.add_comment(account, issue, comment_data)
        comment = account.add_submitted_comment(comment_data)
        issue.add_comment(comment)
    rescue Sequel::MassAssignmentRestriction
        raise IllegalRequestError
    end

    private_class_method :add_comment
  end
end