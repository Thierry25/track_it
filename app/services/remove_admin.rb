# frozen_string_literal: true

module TrackIt
  # Service Object to remove admin in a department
  class RemoveAdmin
    # Error for account without authorization
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove this account as admin of this department'
      end
    end

    def self.call(account:, department:, admin_email:)
      admin = Account.first(email: admin_email)
      policy = AdminRequestPolicy.new(department, account, admin)

      raise ForbiddenError unless policy.can_remove_admin?

      remove_admin(department, admin)
      admin
    end

    def self.remove_admin(department, admin)
      department.employees.reject do |emp|
        emp.id == admin.id
      end
    end

    private_class_method :remove_admin
  end
end
