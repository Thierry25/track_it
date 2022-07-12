# frozen_string_literal: true

module TrackIt
  # Service object to create an issue for a submitter
  class CreateIssueForSubmitter
    def self.call(submitter_id:, issue_data:)
      Account.find(id: submitter_id).add_issue(issue_data)
    end
  end
end
