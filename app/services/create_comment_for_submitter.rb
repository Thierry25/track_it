# frozen_string_literal: true

module TrackIt
  # Service object to create comment for a submitter
  class CreateCommentForSubmitter
    def self.call(submitter_id:, comment_data:)
      Account.find(id: submitter_id).add_submitted_comment(comment_data)
    end
  end
end
