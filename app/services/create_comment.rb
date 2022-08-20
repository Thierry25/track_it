# frozen_string_literal: true

module TrackIt
  # Service object to create comment for a submitter
  class CreateComment
    # Error for not having the right to add a new comment to a project
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more comments'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a comment with those attributes'
      end
    end

    def self.call(account:, project:, comment_data:)
      policy = ProjectPolicy.new(account, project)
      raise ForbiddenError unless policy.can_add_comments?

      add_comment(account, project, comment_data)
    end

    def self.add_comment(account, project, comment_data)
      comment = account.add_submitted_comment(comment_data)
      project.add_comment(comment) if comment
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end

    private_class_method :add_comment
  end
end
