# frozen_string_literal: true

module TrackIt
  # Service Object to allow account to get access to organization
  class GetOrganizationQuery
    # Error for account not having access to see organization
    class ForbiddenError < StandardError
      def message
        'You are not allowed to see this organization'
      end
    end

    # Error for organization not found
    class NotFoundError < StandardError
      def message
        'We could not find this organization'
      end
    end

    def self.call(requestor:, organization:)
      raise NotFoundError unless organization

      policy = OrganizationPolicy.new(requestor, organization)
      raise ForbiddenError unless policy.can_view?

      organization.full_details.merge(policies: policy.summary)
    end
  end
end
