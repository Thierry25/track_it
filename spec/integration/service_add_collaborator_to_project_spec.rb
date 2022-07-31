# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator to Project' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    # Create an organization
    organization_data = DATA[:organizations].first

    @owner = TrackIt::Account.all[0]
    @not_collaborator = TrackIt::Account.all[4]
    @collaborator = TrackIt::Account.all[7]

    @organization = TrackIt::CreateOrganizationForOwner.call(
      owner_id: @owner.id, organization_data:
    )

    # Create a department
    department_data = DATA[:departments].first
    @department = TrackIt::CreateDepartmentForOrganization.call(
      organization_id: @organization.id, department_data:
    )

    # Add two employees to the department
    TrackIt::AddEmployeeToDepartment.call(
      department_id: @department.id, email: @collaborator.email, role_id: 3
    )
    TrackIt::AddEmployeeToDepartment.call(
      department_id: @department.id, email: @not_collaborator.email, role_id: 2
    )

    # Add project to the department
    project_data = DATA[:projects].first

    @project = TrackIt::CreateProjectForDepartment.call(
      department_id: @department.id, project_data:
    )
  end

  it 'HAPPY: should be able to add collaborator to project' do
    TrackIt::AddCollaboratorToProject.call(
      project_id: @project.id, email: @collaborator.email
    )

    _(@collaborator.collaborations.count).must_equal 1
    _(@collaborator.collaborations.first).must_equal @project
  end

  it 'BAD: should not add owner as a collaborator' do
    _(proc {
      TrackIt::AddCollaboratorToProject.call(
        project_id: @project.id, email: @owner.email
      )
    }).must_raise TrackIt::AddCollaboratorToProject::AccountNotCollaborator
  end

  it 'BAD: should not add non software-engineer as a collaborator' do
    _(proc {
      TrackIt::AddCollaboratorToProject.call(
        project_id: @project.id, email: @not_collaborator.email
      )
    }).must_raise TrackIt::AddCollaboratorToProject::AccountNotCollaborator
  end
end
