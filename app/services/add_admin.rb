# frozen_string_literal: true

module TrackIt
  # Service object to add admin to a department
  class AddAdmin
    # Error for account that does not have the authorization to add admin
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add this account as admin'
      end
    end

    def self.call(account:, department_id:, admin_email:)
      admin = Account.first(email: admin_email)
      department = Department.first(id: department_id)
      policy = AdminRequestPolicy.new(department, account, admin)

      raise ForbiddenError unless policy.can_add_admin?

      TrackIt::Api.DB[:accounts_departments]
                  .insert(department_id:, employee_id: admin.id, role_id: 1)
      admin
    end
  end
end
