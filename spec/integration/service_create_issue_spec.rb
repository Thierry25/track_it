# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test create a new issue' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    @manager = TrackIt::Account.all[2]
    @soft_dev = TrackIt::Account.all[4]
    @tester = TrackIt::Account.all[5]

    # CREATION DATA
    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first
    project_data = DATA[:projects].first

    # wrong data
    @not_employee = TrackIt::Account.all[6]
    @admin = TrackIt::Account.all[3]

    # Create organization
    @org = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    # Create department
    @dep = TrackIt::CreateDepartment.call(
      account: @owner, organization: @org, department_data:
    )

    # Create project
    @proj = TrackIt::CreateProject.call(
      account: @owner, department: @dep, project_data:
    )

    # Add Admin, Proj Manager, Soft dev, Tester
    TrackIt::AddAdmin.call(
      account: @owner, department_id: @dep.id, admin_email: @admin.email
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @manager.email, role_id: 2
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @soft_dev.email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @tester.email, role_id: 4
    )

    @proj.add_manager(@manager)
  end

  it 'HAPPY: manager should be able to create a new issue within a project' do
    issue_data = DATA[:issues].first

    issue = TrackIt::CreateIssue.call(
      account: @manager,
      project: @proj,
      issue_data:
    )

    _(@proj.issues.count).must_equal 1
    _(@proj.issues.first).must_equal issue
  end

  it 'HAPPY: soft dev should be able to create a new issue within a project' do
    @proj.add_collaborator(@soft_dev)
    issue_data = DATA[:issues].first

    issue = TrackIt::CreateIssue.call(
      account: @soft_dev,
      project: @proj,
      issue_data:
    )

    _(@proj.issues.count).must_equal 1
    _(@proj.issues.first).must_equal issue
  end

  it 'HAPPY: tester should be able to create a new issue within a project' do
    @proj.add_collaborator(@tester)
    issue_data = DATA[:issues].first

    issue = TrackIt::CreateIssue.call(
      account: @tester,
      project: @proj,
      issue_data:
    )

    _(@proj.issues.count).must_equal 1
    _(@proj.issues.first).must_equal issue
  end

  it 'SAD: soft dev cannot add issue if not collaborator' do
    _(proc {
      issue_data = DATA[:issues].first

      TrackIt::CreateIssue.call(
        account: @soft_dev,
        project: @proj,
        issue_data:
      )
    }).must_raise TrackIt::CreateIssue::ForbiddenError
  end

  it 'SAD: tester cannot add issue if not collaborator' do
    _(proc {
      issue_data = DATA[:issues].first

      TrackIt::CreateIssue.call(
        account: @tester,
        project: @proj,
        issue_data:
      )
    }).must_raise TrackIt::CreateIssue::ForbiddenError
  end

  it 'SAD: owner cannot add issue' do
    _(proc {
      issue_data = DATA[:issues].first

      TrackIt::CreateIssue.call(
        account: @owner,
        project: @proj,
        issue_data:
      )
    }).must_raise TrackIt::CreateIssue::ForbiddenError
  end

  it 'SAD: admin cannot add issue' do
    _(proc {
      issue_data = DATA[:issues].first

      TrackIt::CreateIssue.call(
        account: @admin,
        project: @proj,
        issue_data:
      )
    }).must_raise TrackIt::CreateIssue::ForbiddenError
  end
end
