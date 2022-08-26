# frozen_string_literal: true

module TrackIt
  # Policy to determine if account can view organizations
  class OrganizationPolicy
    # Scope of organization policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_organizations(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |organization|
            includes_employee?(organization, @current_account)
          end
        end
      end

      private

      def all_organizations(account)
        account.owned_organizations + account.companies
      end

      def includes_employee?(organization, account)
        organization.employees.include? account
      end
    end
  end
end
