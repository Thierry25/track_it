# frozen_string_literal: true

module TrackIt
  # Service object to create a new organization for an owner -> Granting him/her the superAdmin privilege
  class CreateOrganizationForOwner
    def self.call(owner_id:, organization_data:)
      Account.find(id: owner_id).add_owned_organizations(organization_data)
    end
  end
end
