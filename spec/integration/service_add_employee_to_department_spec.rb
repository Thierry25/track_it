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

    # Create organization
    organization_data = DATA[:organizations].first

    @organization = TrackIt::CreateOrganizationForOwner.call(
      owner_id: @owner.id, organization_data:
    )

    # Create Department
    department_data = DATA[:departments].first

    @department = TrackIt::CreateDepartmentForOrganization.call(
      organization_id: @organization.id, department_data:
    )
  end

  it 'HAPPY: should be able to add employee to department' do
    TrackIt::AddEmployeeToDepartment.call(
      department_id: @department.id, email: @employee_to_add.email, role_id: 3
    )

    _(@employee_to_add.teams.count).must_equal 1
    _(@employee_to_add.teams.first.id).must_equal @department.id
  end

  it 'SAD: should not be able to add owner to department' do
    _(proc {
      TrackIt::AddEmployeeToDepartment.call(
        department_id: @department.id, email: @owner.email, role_id: 3
      )
    }).must_raise TrackIt::AddEmployeeToDepartment::OwnerNotEmployeeError
  end
end
