# frozen_string_literal: true

module TrackIt
  # Service object to add collaborator to a project
  class AddCollaborator
    # Error account cannot be a collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite this account as collaborator to project'
      end
    end

    def self.call(account:, project:, collaborator_email:)
      invitee = Account.first(email: collaborator_email)
      policy = CollaborationRequestPolicy.new(project, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      project.add_collaborator(invitee)
      invitee
    end
  end
end
