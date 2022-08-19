# frozen_string_literal: true

module TrackIt
  # Service object to add issue to a project
  class AddIssue
    def self.call(project_id:, issue_id:)
      project = Project.first(id: project_id)
      issue = Issue.first(id: issue_id)

      project.add_issue(issue)
    end
  end
end
