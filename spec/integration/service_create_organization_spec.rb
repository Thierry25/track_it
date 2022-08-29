# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test create organization' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
  end

  it 'HAPPY: should be able to create new organization' do
    organization_data = DATA[:organizations][1]

    organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    _(@owner.owned_organizations.count).must_equal 1
    _(@owner.owned_organizations.first).must_equal organization
  end
end
