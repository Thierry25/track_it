# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddAssignIssue service' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    # Create an organization
    organization_data = DATA[:organizations].first

    @owner = TrackIt::Account.all[0]
    @admin = TrackIt::Account.all[2]
    @manager = TrackIt::Account.all[3]
    @tester = TrackIt::Account.all[6]

    @assignee = TrackIt::Account.last

    @not_employee = TrackIt::Account.all[7]

    @organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    # Create a department
    department_data = DATA[:departments].first
    @department = TrackIt::CreateDepartment.call(
      account: @owner, organization: @organization, department_data:
    )

    # Create a project
    project_data = DATA[:projects].first
    @project = TrackIt::CreateProject.call(
      account: @owner, department: @department, project_data:
    )

    # Create issue
    issue_data = DATA[:issues].first

    # Add admin to department for testing
    TrackIt::AddAdmin.call(
      account: @owner,
      department_id: @department.id,
      admin_email: @admin.email
    )

    # Add project manager for testing
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @manager.email,
      role_id: 2
    )

    @project.add_manager(@manager)

    # Add assignee to department for testing
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @assignee.email,
      role_id: 3
    )

    # Add tester to department for testing
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @tester.email,
      role_id: 4
    )

    @issue = TrackIt::CreateIssue.call(
      account: @assignee,
      project: @project,
      issue_data:
    )
  end

  it 'HAPPY: manager should able to assign an issue to an account' do
    @project.add_collaborator(@assignee)
    TrackIt::AssignIssue.call(
      account: @manager,
      issue: @issue,
      assignee_email: @assignee.email
    )

    _(@assignee.assigned_issues.count).must_equal 1
    _(@assignee.assigned_issues.first).must_equal @issue
  end

  it 'HAPPY: admin should able to assign an issue to an account' do
    @project.add_collaborator(@assignee)
    TrackIt::AssignIssue.call(
      account: @admin,
      issue: @issue,
      assignee_email: @assignee.email
    )

    _(@assignee.assigned_issues.count).must_equal 1
    _(@assignee.assigned_issues.first).must_equal @issue
  end

  it 'BAD: owner should not be able to assign issue' do
    @project.add_collaborator(@assignee)
    _(proc {
        TrackIt::AssignIssue.call(
          account: @owner,
          issue: @issue,
          assignee_email: @assignee.email
        )
      }).must_raise TrackIt::AssignIssue::ForbiddenError
  end

  it 'BAD: should not add owner as assignee' do
    _(proc {
      TrackIt::AssignIssue.call(
        account: @admin,
        issue: @issue,
        assignee_email: @owner.email
      )
    }).must_raise TrackIt::AssignIssue::ForbiddenError
  end

  it 'BAD: should not add an admin as assignee' do
    _(proc {
        TrackIt::AssignIssue.call(
          account: @manager,
          issue: @issue,
          assignee_email: @admin.email
        )
      }).must_raise TrackIt::AssignIssue::ForbiddenError
  end

  it 'BAD: should not add a project manager as assignee' do
    _(proc {
        TrackIt::AssignIssue.call(
          account: @admin,
          issue: @issue,
          assignee_email: @manager.email
        )
      }).must_raise TrackIt::AssignIssue::ForbiddenError
  end

  it 'BAD: should not add a tester as assignee' do
    @project.add_collaborator(@tester)
    _(proc {
        TrackIt::AssignIssue.call(
          account: @manager,
          issue: @issue,
          assignee_email: @tester.email
        )
      }).must_raise TrackIt::AssignIssue::ForbiddenError
  end

  it 'BAD: should not add anyone without being a collaborator to the project' do
    _(proc {
        TrackIt::AssignIssue.call(
          account: @manager,
          issue: @issue,
          assignee_email: @assignee.email
        )
      }).must_raise TrackIt::AssignIssue::ForbiddenError
  end
end
