# frozen_string_literal: true

module TrackIt
  # Service object to create comment for a submitter
  class CreateCommentForSubmitter
    def self.call(submitter_id:, comment_id:)
      Account.find(id: submitter_id).add_submitted_comment(comment_id)
    end
  end
end
