# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator to Project' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first
    project_data = DATA[:projects].first

    @owner = TrackIt::Account.all[0]
    @not_collaborator = TrackIt::Account.all[4]
    @collaborator = TrackIt::Account.all[7]

    @organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    @department = TrackIt::CreateDepartment.call(
      account: @owner, organization: @organization, department_data:
    )

    @project = TrackIt::CreateProject.call(
      account: @owner, department: @department, project_data:
    )

    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @collaborator.email,
      role_id: 3
    )
  end

  it 'HAPPY: should be able to add a software developer as collaborator to project' do
    TrackIt::AddCollaborator.call(
      account: @owner,
      project: @project,
      collaborator_email: @collaborator.email
    )

    _(@collaborator.collaborations.count).must_equal 1
    _(@collaborator.collaborations.first).must_equal @project
  end

  it 'HAPPY: should be able to add a tester as collaborator to project' do
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @not_collaborator.email,
      role_id: 4
    )

    TrackIt::AddCollaborator.call(
      account: @owner,
      project: @project,
      collaborator_email: @not_collaborator.email
    )

    _(@not_collaborator.collaborations.count).must_equal 1
    _(@not_collaborator.collaborations.first).must_equal @project
  end

  it 'BAD: should not add owner as a collaborator' do
    _(proc {
      TrackIt::AddCollaborator.call(
        account: @owner,
        project: @project,
        collaborator_email: @owner.email
      )
    }).must_raise TrackIt::AddCollaborator::ForbiddenError
  end

  it 'BAD: should not add a non-employee as a collaborator' do
    _(proc {
      TrackIt::AddCollaborator.call(
        account: @owner,
        project: @project,
        collaborator_email: @not_collaborator.email
      )
    }).must_raise TrackIt::AddCollaborator::ForbiddenError
  end

  it 'BAD: should not add admin as a collaborator' do
    TrackIt::AddAdmin.call(
      account: @owner,
      department_id: @department.id,
      admin_email: @not_collaborator.email
    )
    _(proc {
        TrackIt::AddCollaborator.call(
          account: @owner,
          project: @project,
          collaborator_email: @not_collaborator.email
        )
      }).must_raise TrackIt::AddCollaborator::ForbiddenError
  end

  it 'BAD: should not add project manager as a collaborator' do
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @not_collaborator.email,
      role_id: 2
    )
    _(proc {
        TrackIt::AddCollaborator.call(
          account: @owner,
          project: @project,
          collaborator_email: @not_collaborator.email
        )
      }).must_raise TrackIt::AddCollaborator::ForbiddenError
  end

  it 'BAD AUTHORIZATION: should not add collaborator with wrong authorization' do
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @not_collaborator.email,
      role_id: 3
    )
    _(proc {
        TrackIt::AddCollaborator.call(
          account: @collaborator,
          project: @project,
          collaborator_email: @not_collaborator.email
        )
      }).must_raise TrackIt::AddCollaborator::ForbiddenError
  end
end
