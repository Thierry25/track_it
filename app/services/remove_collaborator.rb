# frozen_string_literal: true

module TrackIt
  # Service Object to remove a collaborator in a project
  class RemoveCollaborator
    # Error account cannot remove collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove collaborator from project'
      end
    end

    def self.call(account:, project:, collaborator_email:)
      collaborator = Account.first(email: collaborator_email)
      policy = CollaborationRequestPolicy.new(project, account, collaborator)
      raise ForbiddenError unless policy.can_remove?

      project.remove_collaborator(collaborator)
      collaborator
    end
  end
end
