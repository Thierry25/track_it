# frozen_strong_literal: true

module TrackIt
  # Policy to determine if an account can add/remove collaborator to a project
  class CollaborationRequestPolicy
    def initialize(project, requestor_account, target_account)
      @project = project
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = ProjectPolicy.new(requestor_account, project)
      @target = ProjectPolicy.new(target_account, project)
    end

    def can_invite?
      @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      @requestor.can_remove_collaborators && target_is_collaborator?
    end

    private

    def target_is_collaborator?
      @project.collaborators.include?(@target_account)
    end
  end
end
