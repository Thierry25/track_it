# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddAssignIssueToAccount service' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    # Create an organization
    organization_data = DATA[:organizations].first

    @owner = TrackIt::Account.all[0]
    @not_software_engineer = TrackIt::Account.all[4]
    @issue_submitter = TrackIt::Account.all[5]
    @assignee = TrackIt::Account.all[9]
    @organization = TrackIt::CreateOrganizationForOwner.call(
      owner_id: @owner.id, organization_data:
    )

    # Create a department
    department_data = DATA[:departments].first
    @department = TrackIt::CreateDepartmentForOrganization.call(
      organization_id: @organization.id, department_data:
    )

    # Add assignee to department for testing
    TrackIt::AddEmployeeToDepartment.call(
      department_id: @department.id, email: @assignee.email, role_id: 3
    )

    TrackIt::AddEmployeeToDepartment.call(
      department_id: @department.id, email: @not_software_engineer.email, role_id: 2
    )

    # Create a project
    project_data = DATA[:projects].first
    @project = TrackIt::CreateProjectForDepartment.call(
      department_id: @department.id, project_data:
    )

    # Create issue
    issue_data = DATA[:issues].first
    @issue = TrackIt::CreateIssueForSubmitter.call(
      submitter_id: @issue_submitter.id, issue_data:
    )

    # Add issue to project for testing
    TrackIt::AddIssueToProject.call(
      project_id: @project.id, issue_id: @issue.id
    )
  end

  it 'HAPPY: should able to assign an issue to an account' do
    TrackIt::AssignIssueToAccount.call(
      issue_id: @issue.id,
      email: @assignee.email,
      department_id: @department.id
    )

    _(@assignee.assigned_issues.count).must_equal 1
    _(@assignee.assigned_issues.first).must_equal @issue
  end

  it 'BAD: should not add owner as assignee' do
    _(proc {
      TrackIt::AssignIssueToAccount.call(
        issue_id: @issue.id,
        email: @owner.email,
        department_id: @department.id
      )
    }).must_raise TrackIt::AssignIssueToAccount::AccountNotAssigneeError
  end

  it 'BAD: should not add non software-engineers as assignee' do
    _(proc {
        TrackIt::AssignIssueToAccount.call(
          issue_id: @issue.id,
          email: @not_software_engineer.email,
          department_id: @department.id
        )
      }).must_raise TrackIt::AssignIssueToAccount::AccountNotAssigneeError
  end
end
