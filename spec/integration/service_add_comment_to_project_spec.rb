# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddComment to Project' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    @owner = TrackIt::Account.first
    @submitter = TrackIt::Account.all[4]

    organization_data = DATA[:organizations].first

    # Create organization
    @organization = TrackIt::CreateOrganizationForOwner.call(
      owner_id: @owner.id, organization_data:
    )

    department_data = DATA[:departments].first

    @department = TrackIt::CreateDepartmentForOrganization.call(
      organization_id: @organization.id, department_data:
    )

    project_data = DATA[:projects].first

    @project = TrackIt::CreateProjectForDepartment.call(
      department_id: @department.id, project_data:
    )

    comment_data = DATA[:comments].first

    @comment = TrackIt::CreateCommentForSubmitter.call(
      submitter_id: @submitter.id, comment_data:
    )
  end

  it 'HAPPY: Should add comment to project' do
    TrackIt::AddCommentToProject.call(
      project_id: @project.id, comment_id: @comment.id
    )

    _(@project.comments.count).must_equal 1
    _(@project.comments.first).must_equal @comment
  end
end
