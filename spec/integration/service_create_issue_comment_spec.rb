# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test create issue comment' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    @owner = TrackIt::Account.first
    @manager = TrackIt::Account.all[2]
    @admin = TrackIt::Account.all[3]
    @assignee = TrackIt::Account.all[4]

    # CREATION DATA
    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first
    project_data = DATA[:projects].first
    issue_data = DATA[:issues].first

    # wrong data
    @tester = TrackIt::Account.all[5]
    @not_employee = TrackIt::Account.all[6]

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

    # Add Admin, Proj Manager, Assignee, Tester
    TrackIt::AddAdmin.call(
      account: @owner, department_id: @dep.id, admin_email: @admin.email
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @manager.email, role_id: 2
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @assignee.email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @tester.email, role_id: 4
    )

    @proj.add_collaborator(@assignee)
    # Create issue
    @issue = TrackIt::CreateIssue.call(
      account: @assignee,
      project: @proj,
      issue_data:
    )

    @proj.add_manager(@manager)
    @issue.add_assignee(@assignee)
  end

  it 'HAPPY: manager should be able to create comment related to an issue' do
    comment_data = DATA[:comments].first

    comment = TrackIt::CreateIssueComment.call(
      account: @manager, issue: @issue, comment_data:
    )

    _(@issue.comments.count).must_equal 1
    _(@issue.comments.first).must_equal comment
  end

  it 'HAPPY: admin should be able to create comment related to an issue' do
    comment_data = DATA[:comments].first

    comment = TrackIt::CreateIssueComment.call(
      account: @admin, issue: @issue, comment_data:
    )

    _(@issue.comments.count).must_equal 1
    _(@issue.comments.first).must_equal comment
  end

  it 'HAPPY: assignee should be able to create comment related to an issue' do
    comment_data = DATA[:comments].first

    comment = TrackIt::CreateIssueComment.call(
      account: @assignee, issue: @issue, comment_data:
    )

    _(@issue.comments.count).must_equal 1
    _(@issue.comments.first).must_equal comment
  end

  it 'SAD: should not allow tester to create comment related to an issue' do
    _(proc {
      comment_data = DATA[:comments].first

      TrackIt::CreateIssueComment.call(
        account: @tester, issue: @issue, comment_data:
      )
    }).must_raise TrackIt::CreateIssueComment::ForbiddenError
  end

  it 'SAD: should not allow non-employee to create comment related to an issue' do
    _(proc {
      comment_data = DATA[:comments].first

      TrackIt::CreateIssueComment.call(
        account: @tester, issue: @issue, comment_data:
      )
    }).must_raise TrackIt::CreateIssueComment::ForbiddenError
  end

  # account_is_manager? || account_is_admin? || account_is_assignee?
end
