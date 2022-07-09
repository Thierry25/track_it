# frozen_string_literal: true

module TrackIt
  # Service object that creates a comment about a project for a commentor
  class CreateProjectCommentForCommenter
    def self.call(commenter_id:, comment_data:)
      Account.find(id: commenter_id).add_submitted_issues_comments(comment_data)
    end
  end
end
