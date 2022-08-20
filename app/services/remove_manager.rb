# frozen_string_literal: true

module TrackIt
  # Service Object to remove a manager from a project
  class RemoveManager
    # Error for account that can not remove manager
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove this account as manager'
      end
    end

    def self.call(account:, project:, manager_email:)
      manager = Account.first(email: manager_email)
      policy = ManagerRequestPolicy.new(project, account, manager)
      raise ForbiddenError unless policy.can_remove_manager?

      project.remove_manager(manager)
      manager
    end
  end
end
