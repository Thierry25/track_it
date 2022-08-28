# frozen_string_literal: true

module TrackIt
  # Policy to determine organization's access by account
  class OrganizationPolicy
    def initialize(account, organization)
      @account = account
      @organization = organization
    end

    def can_view?
      account_is_owner? || account_is_employee?
    end

    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_add_departments?
      account_is_owner?
    end

    def can_remove_departments?
      account_is_owner?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_departments: can_add_departments?,
        can_remove_departments: can_remove_departments?
      }
    end

    private

    def account_is_owner?
      @organization.owner == @account
    end

    def account_is_employee?
      @organization.employees&.include? @account
    end
  end
end
