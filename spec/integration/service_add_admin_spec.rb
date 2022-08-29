# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddAdmin service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first

    @owner = TrackIt::Account.all[0]
    @admin = TrackIt::Account.all[1]
    @admin2 = TrackIt::Account.all[2]

    # BAD DATA
    @proj_manager = TrackIt::Account.all[3]
    @soft_dev = TrackIt::Account.all[4]
    @tester = TrackIt::Account.all[5]

    @organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    @department = TrackIt::CreateDepartment.call(
      account: @owner, organization: @organization, department_data:
    )
  end

  it 'HAPPY: should be able to add an admin to a department' do
    TrackIt::AddAdmin.call(
      account: @owner,
      department_id: @department.id,
      admin_email: @admin.email
    )

    _(@admin.administrated_departments.count).must_equal 1
    _(@admin.administrated_departments.first.id).must_equal @department.id
  end

  describe 'Adding more than one admin handling' do
    before do
      TrackIt::AddAdmin.call(
        account: @owner,
        department_id: @department.id,
        admin_email: @admin.email
      )
    end
    it 'SAD: should not be able to add more than one admin' do
      _(proc {
          TrackIt::AddAdmin.call(
            account: @owner,
            department_id: @department.id,
            admin_email: @admin2.email
          )
        }).must_raise TrackIt::AddAdmin::ForbiddenError
    end
  end

  it 'BAD: should not add owner as an admin' do
    _(proc {
      TrackIt::AddAdmin.call(
        account: @owner,
        department_id: @department.id,
        admin_email: @owner.email
      )
    }).must_raise TrackIt::AddAdmin::ForbiddenError
  end
end
