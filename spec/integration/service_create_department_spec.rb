# frozen_string_literal

require_relative '../spec_helper'

describe 'Test create department' do
  before do
    wipe_database
    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    organization_data = DATA[:organizations].first
    @not_owner = TrackIt::Account.all[5]

    @organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )
  end

  it 'HAPPY: should allow owner of organization to create a department' do
    department_data = DATA[:departments].last
    department = TrackIt::CreateDepartment.call(
      account: @owner, organization: @organization, department_data:
    )

    _(@organization.departments.count).must_equal 1
    _(@organization.departments.first).must_equal department
  end

  it 'SAD: should not allow non-owner of organization to create a department within an organization' do
    _(proc {
      department_data = DATA[:departments].last
      TrackIt::CreateDepartment.call(
        account: @not_owner, organization: @organization, department_data:
      )
    }).must_raise TrackIt::CreateDepartment::ForbiddenError
  end
end
