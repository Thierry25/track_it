# frozen_string_literal: true

module TrackIt
  # Service object that creates a comment about an issue for a commentor
  class CreateIssueCommentForCommenter
    def self.call(commenter_id:, comment_data:)
      Account.find(id: commenter_id).add_submitted_issues_comments(comment_data)
    end
  end
end
