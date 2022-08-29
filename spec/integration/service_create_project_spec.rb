# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test create project' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    @admin = TrackIt::Account.all[2]
    @proj_manager = TrackIt::Account.all[3]
    @soft_dev = TrackIt::Account.all[4]
    @tester = TrackIt::Account.all[5]

    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first

    @org = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    @dep = TrackIt::CreateDepartment.call(
      account: @owner, organization: @org, department_data:
    )

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
    @project_data = DATA[:projects].first
  end

  it 'HAPPY: owner should be able to create a new project within a department' do
    proj = TrackIt::CreateProject.call(
      account: @owner, department: @dep, project_data: @project_data
    )

    _(@dep.projects.count).must_equal 1
    _(@dep.projects.first).must_equal proj
  end

  it 'HAPPY: admin should be able to create a new project within a department' do
    proj = TrackIt::CreateProject.call(
      account: @admin, department: @dep, project_data: @project_data
    )

    _(@dep.projects.count).must_equal 1
    _(@dep.projects.first).must_equal proj
  end

  it 'SAD: proj manager should not be able to create a new project' do
    _(proc {
      TrackIt::CreateProject.call(
        account: @proj_manager, department: @dep, project_data: @project_data
      )
    }).must_raise TrackIt::CreateProject::ForbiddenError
  end

  it 'SAD: soft dev should not be able to create a new project' do
    _(proc {
      TrackIt::CreateProject.call(
        account: @soft_dev, department: @dep, project_data: @project_data
      )
    }).must_raise TrackIt::CreateProject::ForbiddenError
  end

  it 'SAD: tester should not be able to create a new project' do
    _(proc {
      TrackIt::CreateProject.call(
        account: @tester, department: @dep, project_data: @project_data
      )
    }).must_raise TrackIt::CreateProject::ForbiddenError
  end
end
