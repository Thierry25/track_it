# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Organization Handling' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data) if account_data['role'] == 'super'
    end
  end

  it 'HAPPY: should retrieve correct data from DB' do
    organization_data = DATA[:organizations][1]
    account = TrackIt::Account.first
    new_organization = account.add_owned_organization(organization_data)

    organization = TrackIt::Organization.find(id: new_organization.id)
    _(organization.identifier).must_equal organization_data['identifier']
    _(organization.name).must_equal organization_data['name']
    _(organization.country).must_equal organization_data['country']
  end
end
