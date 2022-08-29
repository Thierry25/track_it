# frozen_string_literal: true

module TrackIt
  # Service Object to add a project to the list of managed projects
  class AddManager
    # Error for account can't add another account as manager
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as project manager'
      end
    end

    def self.call(account:, project:, manager_email:)
      manager = Account.first(email: manager_email)
      policy = ManagerRequestPolicy.new(project, account, manager)
      raise ForbiddenError unless policy.can_add_manager?

      project.add_manager(manager)
      manager
    end
  end
end
