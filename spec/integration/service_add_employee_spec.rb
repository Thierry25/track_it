# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddEmployee to department' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    @owner = TrackIt::Account.first
    @employee_to_add = TrackIt::Account.all[7]
    @admin = TrackIt::Account.last
    @wrong_account = TrackIt::Account.all[5]

    # Create organization
    organization_data = DATA[:organizations].first

    @organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    # Create Department
    department_data = DATA[:departments].first

    @department = TrackIt::CreateDepartment.call(
      account: @owner, organization: @organization, department_data:
    )
  end

  it 'HAPPY: owner should be able to add employee to department' do
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @employee_to_add.email,
      role_id: 3
    )

    _(@employee_to_add.teams.count).must_equal 1
    _(@employee_to_add.teams.first.id).must_equal @department.id
  end

  it 'HAPPY: admin should be able to add employee to department' do
    TrackIt::AddAdmin.call(
      account: @owner,
      department_id: @department.id,
      admin_email: @admin.email
    )
    TrackIt::AddEmployee.call(
      account: @admin,
      department_id: @department.id,
      employee_email: @employee_to_add.email,
      role_id: 3
    )

    _(@employee_to_add.teams.count).must_equal 1
    _(@employee_to_add.teams.first.id).must_equal @department.id
  end

  it 'SAD: should not be able to add owner to department' do
    _(proc {
      TrackIt::AddEmployee.call(
        account: @owner,
        department_id: @department.id,
        employee_email: @owner.email,
        role_id: 3
      )
    }).must_raise TrackIt::AddEmployee::ForbiddenError
  end

  it 'BAD AUTHORIZATION: non-onwer and non-admin to department' do
    _(proc {
        TrackIt::AddEmployee.call(
          account: @wrong_account,
          department_id: @department.id,
          employee_email: @employee_to_add.email,
          role_id: 3
        )
      }).must_raise TrackIt::AddEmployee::ForbiddenError
  end
end
