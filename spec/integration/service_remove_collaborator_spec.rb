# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test remove collaborator' do
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
    @not_employee = TrackIt::Account.last

    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first
    project_data = DATA[:projects].first

    @org = @owner.add_owned_organization(organization_data)
    @dep = @org.add_department(department_data)
    @proj = @dep.add_project(project_data)

    TrackIt::AddAdmin.call(
      account: @owner, department_id: @dep.id, admin_email: @admin.email
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

    @proj.add_collaborator(@soft_dev)
    @proj.add_manager(@proj_manager)
  end

  it 'HAPPY: owner should be able to remove collaborator from project' do
    _(@proj.collaborators.count).must_equal 1
    _(@proj.collaborators.first).must_equal @soft_dev

    TrackIt::RemoveCollaborator.call(
      account: @owner, project: @proj, collaborator_email: @soft_dev.email
    )

    _(@proj.collaborators.count).must_equal 0
  end

  it 'HAPPY: proj manager should be able to remove collaborator from project' do
    _(@proj.collaborators.count).must_equal 1
    _(@proj.collaborators.first).must_equal @soft_dev

    TrackIt::RemoveCollaborator.call(
      account: @proj_manager, project: @proj, collaborator_email: @soft_dev.email
    )

    _(@proj.collaborators.count).must_equal 0
  end

  it 'HAPPY: admin should be able to remove collaborator from project' do
    _(@proj.collaborators.count).must_equal 1
    _(@proj.collaborators.first).must_equal @soft_dev

    TrackIt::RemoveCollaborator.call(
      account: @admin, project: @proj, collaborator_email: @soft_dev.email
    )

    _(@proj.collaborators.count).must_equal 0
  end

  it 'SAD: soft dev should not be able to remove not employee' do
    _(proc {
      TrackIt::RemoveCollaborator.call(
        account: @admin, project: @proj, collaborator_email: @not_employee.email
      )
    }).must_raise TrackIt::RemoveCollaborator::ForbiddenError
  end

  it 'SAD: soft dev should not be able to remove collaborator from project' do
    @proj.add_collaborator(@tester)
    _(proc {
      TrackIt::RemoveCollaborator.call(
        account: @soft_dev, project: @proj, collaborator_email: @tester.email
      )
    }).must_raise TrackIt::RemoveCollaborator::ForbiddenError
  end

  it 'SAD: tester should not be able to remove collaborator from project' do
    _(proc {
      TrackIt::RemoveCollaborator.call(
        account: @tester, project: @proj, collaborator_email: @soft_dev.email
      )
    }).must_raise TrackIt::RemoveCollaborator::ForbiddenError
  end
end
