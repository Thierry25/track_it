# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddIssue to Project' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    @owner = TrackIt::Account.first
    @issue_submitter = TrackIt::Account.all[4]
    @issue_to_add = TrackIt::Issue.first

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

    # Create project
    project_data = DATA[:projects].first

    @project = TrackIt::CreateProjectForDepartment.call(
      department_id: @department.id, project_data:
    )

    # Create issue
    issue_data = DATA[:issues].first

    @issue = TrackIt::CreateIssueForSubmitter.call(
      submitter_id: @issue_submitter.id, issue_data:
    )
  end

  it 'HAPPY: should be able to add issue to a project' do
    TrackIt::AddIssueToProject.call(
      project_id: @project.id, issue_id: @issue.id
    )

    _(@project.issues.count).must_equal 1
    _(@project.issues.first).must_equal @issue
  end
end
