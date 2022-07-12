# frozen_string_literal: true

module TrackIt
  # Service object to add collaborator to a project
  class AddCollaboratorToProject
    # Error Project Manager cannot be a collaborator
    class ProjectManagerNotCollaborator < StandardError
      def message = 'Project Manager cannot be a collaborator'
    end

    def self.call(project_id:, email:)
      collaborator = Account.first(email:)
      project = Project.first(id: project_id)
      raise(ProjectManagerNotCollaborator) if project.managers.all.include? collaborator

      project.add_collaborator(collaborator)
    end
  end
end
