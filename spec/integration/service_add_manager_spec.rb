# frozne_string_literal: true

require_relative '../spec_helper'

describe 'Test AddManager to project' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    @owner = TrackIt::Account.first
    @admin = TrackIt::Account.all[3]
    @manager = TrackIt::Account.all[7]
    @soft_dev = TrackIt::Account.all[5]
    @tester = TrackIt::Account.last
    @not_employee = TrackIt::Account.all[2]

    # Create organization
    organization_data = DATA[:organizations].first
    @organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    # Create department
    department_data = DATA[:departments].first
    @department = TrackIt::CreateDepartment.call(
      account: @owner, organization: @organization, department_data:
    )

    # Add one admin
    TrackIt::AddAdmin.call(
      account: @owner,
      department_id: @department.id,
      admin_email: @admin.email
    )

    # Add a project manager to the department
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @manager.email,
      role_id: 2
    )

    # Add a soft_dev to the department
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @soft_dev.email,
      role_id: 3
    )
    # Add a tester to the department
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @tester.email,
      role_id: 4
    )

    # Create a project
    project_data = DATA[:projects].first
    @project = TrackIt::CreateProject.call(
      account: @owner, department: @department, project_data:
    )
  end

  it 'HAPPY: owner should be able to add manager to a project' do
    TrackIt::AddManager.call(
      account: @owner,
      project: @project,
      manager_email: @manager.email
    )

    _(@manager.managed_projects.count).must_equal 1
    _(@manager.managed_projects.first).must_equal @project
  end

  it 'HAPPY: admin should be able to add manager to a project' do
    TrackIt::AddManager.call(
      account: @admin,
      project: @project,
      manager_email: @manager.email
    )

    _(@manager.managed_projects.count).must_equal 1
    _(@manager.managed_projects.first).must_equal @project
  end

  it 'SAD: should not allow owner to be a project manager' do
    _(proc {
      TrackIt::AddManager.call(
        account: @owner,
        project: @project,
        manager_email: @owner.email
      )
    }).must_raise TrackIt::AddManager::ForbiddenError
  end

  it 'SAD: should not allow admin to be added as project manager' do
    _(proc {
      TrackIt::AddManager.call(
        account: @owner,
        project: @project,
        manager_email: @admin.email
      )
    }).must_raise TrackIt::AddManager::ForbiddenError
  end

  it 'SAD: should not allow soft dev to be added as project manager' do
    _(proc {
      TrackIt::AddManager.call(
        account: @owner,
        project: @project,
        manager_email: @soft_dev.email
      )
    }).must_raise TrackIt::AddManager::ForbiddenError
  end

  it 'SAD: should not allow tester to be added as project manager' do
    _(proc {
      TrackIt::AddManager.call(
        account: @owner,
        project: @project,
        manager_email: @tester.email
      )
    }).must_raise TrackIt::AddManager::ForbiddenError
  end

  it 'SAD: should not allow non-employee to be added as project manager' do
    _(proc {
      TrackIt::AddManager.call(
        account: @owner,
        project: @project,
        manager_email: @not_employee.email
      )
    }).must_raise TrackIt::AddManager::ForbiddenError
  end
end
