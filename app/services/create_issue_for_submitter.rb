# frozen_string_literal: true

module TrackIt
  # Service object to create a new issue issued by an account
  class CreateIssueForSubmitter
    def self.call(submitter_id:, issue_data:)
      Account.find(id: submitter_id).add_submitted_issues(issue_data)
    end
  end
end
