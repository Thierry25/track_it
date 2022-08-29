# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test remove assigned issue' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    @proj_manager = TrackIt::Account.all[2]
    @soft_dev = TrackIt::Account.all[3]
    @tester = TrackIt::Account.all[5]
    @admin = TrackIt::Account.all[7]

    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first
    project_data = DATA[:projects].first
    issue_data = DATA[:issues].first

    @org = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    @dep = TrackIt::CreateDepartment.call(
      account: @owner, organization: @org, department_data:
    )

    @proj = TrackIt::CreateProject.call(
      account: @owner, department: @dep, project_data:
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

    @proj.add_manager(@proj_manager)
    @proj.add_collaborator(@soft_dev)
    @proj.add_collaborator(@tester)

    @issue = TrackIt::CreateIssue.call(
      account: @tester, project: @proj, issue_data:
    )

    @issue.add_assignee(@soft_dev)
  end

  it 'HAPPY: admin should be able to remove assignee from issue' do
    _(@issue.assignees.count).must_equal 1
    _(@issue.assignees.first).must_equal @soft_dev

    TrackIt::RemoveAssignedIssue.call(
      account: @admin, issue: @issue, assignee_email: @soft_dev.email
    )
    _(@issue.assignees.count).must_equal 0
  end

  it 'HAPPY: proj manager should be able to remove assignee from issue' do
    _(@issue.assignees.count).must_equal 1
    _(@issue.assignees.first).must_equal @soft_dev

    TrackIt::RemoveAssignedIssue.call(
      account: @proj_manager, issue: @issue, assignee_email: @soft_dev.email
    )
    _(@issue.assignees.count).must_equal 0
  end

  it 'SAD: owner should not be able to remove assignee from issue' do
    _(proc {
      TrackIt::RemoveAssignedIssue.call(
        account: @owner, issue: @issue, assignee_email: @soft_dev.email
      )
    }).must_raise TrackIt::RemoveAssignedIssue::ForbiddenError
  end

  it 'SAD: soft dev/assignee should not be able to remove assignee from issue' do
    _(proc {
      TrackIt::RemoveAssignedIssue.call(
        account: @soft_dev, issue: @issue, assignee_email: @soft_dev.email
      )
    }).must_raise TrackIt::RemoveAssignedIssue::ForbiddenError
  end

  it 'SAD: tester should not be able to remove assignee from issue' do
    _(proc {
      TrackIt::RemoveAssignedIssue.call(
        account: @tester, issue: @issue, assignee_email: @soft_dev.email
      )
    }).must_raise TrackIt::RemoveAssignedIssue::ForbiddenError
  end
end
