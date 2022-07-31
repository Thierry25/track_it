# frozen_string_literal: true

module TrackIt
  # Service Object to add a comment to a project
  class AddCommentToProject
    def self.call(project_id:, comment_id:)
      project = Project.first(id: project_id)
      comment = Comment.first(id: comment_id)

      project.add_comment(comment)
    end
  end
end
