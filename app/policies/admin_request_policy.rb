# frozen_string_literal: true

module TrackIt
  # Policy to determine if an account can add admin
  class AdminRequestPolicy
    def initialize(department, requestor_account, target_account)
      @department = department
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = DepartmentPolicy.new(requestor_account, department)
      @target = DepartmentPolicy.new(target_account, department)
    end

    def can_add_admin?
      @requestor.can_add_admin? && @target.can_be_admin?
    end

    def can_remove_admin?
      @requestor.can_remove_admin? && target_is_admin?
    end

    private

    def target_is_admin?
      @department.admins&.map(&:id)&.include? @target_account.id
    end
  end
end
