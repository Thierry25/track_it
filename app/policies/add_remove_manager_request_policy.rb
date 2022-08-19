# frozen_string_literal: true

module TrackIt
  # Policy to determine if an account can add/remove manager in a project
  class AddRemoveManagerRequestPolicy
    def initialize(project, requestor_account, target_account)
      @project = project
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = ProjectPolicy.new(requestor_account, project)
      @target = ProjectPolicy.new(target_account, project)
    end

    def can_add_manager?
      @requestor.can_add_managers && @target.can_manage?
    end

    def remove_manager?
      @requestor.can_remove_managers? && target_is_manager?
    end

    private

    def target_is_manager?
      @project.managers.include?(@target_account)
    end
  end
end
