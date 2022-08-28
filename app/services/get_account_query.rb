# frozen_string_literal: true

module TrackIt
  # Service Object to give allow account to see account details
  class GetAccountQuery
    # Error if account does not have access to see details
    class ForbiddenError < StandardError
      def message
        'You are not allowed to see details of this account'
      end
    end

    def self.call(requestor:, username:)
      account = Account.first(username:)

      policy = AccountPolicy.new(requestor, account)
      raise ForbiddenError unless policy.can_view?

      # UPDATE THIS TO KNOW WHICH TYPE OF RESPONSE TO GIVE
      account.full_details.merge(policies: policy.summary)
    end
  end
end
