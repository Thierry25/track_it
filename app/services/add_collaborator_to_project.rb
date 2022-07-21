# frozen_string_literal: true

module TrackIt
  # Service object to add collaborator to a project
  class AddCollaboratorToProject
    # Error Project Manager cannot be a collaborator
    class AccountNotCollaborator < StandardError
      def message = 'Account cannot be a collaborator'
    end

    def self.call(email:, project_id:)
      collaborator = Account.first(email:)
      project = Project.first(id: project_id)

      raise(AccountNotCollaborator) if collaborator.role != 'se' && collaborator.role != 'tester'

      project.add_collaborator(collaborator)
    end
  end
end
