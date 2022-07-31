# frozen_string_literal: true'

module TrackIt
  # Service object to add comment to an issue
  class AddCommentToIssue
    def self.call(issue_id:, comment_id:)
      issue = Issue.first(id: issue_id)
      comment = Comment.first(id: comment_id)

      issue.add_comment(comment)
    end
  end
end
