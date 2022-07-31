# frozne_string_literal: true

require_relative '../spec_helper'

describe 'Test AddManagedProject for manager' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    @owner = TrackIt::Account.first
    @manager = TrackIt::Account.all[7]
    @not_manager = TrackIt::Account.all[5]

    # Create organization
    organization_data = DATA[:organizations].first
    @organization = TrackIt::CreateOrganizationForOwner.call(
      owner_id: @owner.id, organization_data:
    )

    # Create department
    department_data = DATA[:departments].first
    @department = TrackIt::CreateDepartmentForOrganization.call(
      organization_id: @organization.id, department_data:
    )

    # Add two employees to the department
    TrackIt::AddEmployeeToDepartment.call(
      department_id: @department.id, email: @manager.email, role_id: 2
    )
    TrackIt::AddEmployeeToDepartment.call(
      department_id: @department.id, email: @not_manager.email, role_id: 3
    )

    # Create a project
    project_data = DATA[:projects].first
    @project = TrackIt::CreateProjectForDepartment.call(
      department_id: @department.id, project_data:
    )
  end

  it 'HAPPY: should be able to add manager to a project' do
    TrackIt::AddManagedProjectForManager.call(
      email: @manager.email, project_id: @project.id
    )

    _(@manager.managed_projects.count).must_equal 1
    _(@manager.managed_projects.first).must_equal @project
  end

  it 'SAD: should not allow owner to be a project manager' do
    _(proc {
      TrackIt::AddManagedProjectForManager.call(
        email: @owner.email, project_id: @project.id
      )
    }).must_raise TrackIt::AddManagedProjectForManager::AccountNotProjectManagerError
  end

  it 'SAD: should not allow non project-manager to be added' do
    _(proc {
      TrackIt::AddManagedProjectForManager.call(
        email: @not_manager.email, project_id: @project.id
      )
    }).must_raise TrackIt::AddManagedProjectForManager::AccountNotProjectManagerError
  end
end
