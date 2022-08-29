# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test removing admin' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    @admin = TrackIt::Account.all[2]
    @proj_manager = TrackIt::Account.all[4]
    @soft_dev = TrackIt::Account.all[6]
    @tester = TrackIt::Account.all[8]

    organization_data = DATA[:organizations][1]
    department_data = DATA[:departments][1]

    @org = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    @dep = TrackIt::CreateDepartment.call(
      account: @owner, organization: @org, department_data:
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @proj_manager.email, role_id: 2
    )
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @soft_dev.email, role_id: 3
    )
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @tester.email, role_id: 4
    )

    TrackIt::AddAdmin.call(
      account: @owner, department_id: @dep.id, admin_email: @admin.email
    )
  end

  it 'HAPPY: owner should be able to remove an admin' do
    # Check if admin exist first
    _(@dep.admins.count).must_equal 1
    _(@dep.admins.first.id).must_equal @admin.id

    TrackIt::RemoveAdmin.call(
      account: @owner, department: @dep, admin_email: @admin.email
    )

    _(@dep.admins.count).must_equal 0
  end

  it 'SAD: proj manager should not be able to remove admin' do
    _(proc {
      TrackIt::RemoveAdmin.call(
        account: @proj_manager, department: @dep, admin_email: @admin.email
      )
    }).must_raise TrackIt::RemoveAdmin::ForbiddenError
  end

  it 'SAD: soft dev should not be able to remove admin' do
    _(proc {
      TrackIt::RemoveAdmin.call(
        account: @soft_dev, department: @dep, admin_email: @admin.email
      )
    }).must_raise TrackIt::RemoveAdmin::ForbiddenError
  end

  it 'SAD: tester should not be able to remove admin' do
    _(proc {
      TrackIt::RemoveAdmin.call(
        account: @tester, department: @dep, admin_email: @admin.email
      )
    }).must_raise TrackIt::RemoveAdmin::ForbiddenError
  end
end
