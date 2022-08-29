# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test create project comments' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      TrackIt::Account.create(account_data)
    end

    organization_data = DATA[:organizations].first
    department_data = DATA[:departments].first
    project_data = DATA[:projects].first

    @owner = TrackIt::Account.first
    @collaborator = TrackIt::Account.all[1]
    @manager = TrackIt::Account.all[2]
    @admin = TrackIt::Account.all[3]

    @not_collaborator = TrackIt::Account.all[4]
    @not_employee = TrackIt::Account.all[5]

    # Create organization
    @organization = TrackIt::CreateOrganization.call(
      owner_id: @owner.id, organization_data:
    )

    # Create department
    @department = TrackIt::CreateDepartment.call(
      account: @owner, organization: @organization, department_data:
    )

    # Create project
    @proj = TrackIt::CreateProject.call(
      account: @owner, department: @department, project_data:
    )
    @proj.add_collaborator(@collaborator)
    @proj.add_manager(@manager)

    # Create Admin
    TrackIt::AddAdmin.call(
      account: @owner,
      department_id: @department.id,
      admin_email: @admin.email
    )

    # Add not collaborator as employee
    TrackIt::AddEmployee.call(
      account: @owner,
      department_id: @department.id,
      employee_email: @not_collaborator.email,
      role_id: 3
    )
  end

  it 'HAPPY: owner should be able to create a new comment' do
    comment_data = DATA[:comments].first
    comment = TrackIt::CreateComment.call(
      account: @owner, project: @proj, comment_data:
    )

    _(@proj.comments.count).must_equal 1
    _(@proj.comments.first).must_equal comment
  end

  it 'HAPPY: collaborator should be able to create a new comment' do
    comment_data = DATA[:comments].first
    comment = TrackIt::CreateComment.call(
      account: @collaborator, project: @proj, comment_data:
    )

    _(@proj.comments.count).must_equal 1
    _(@proj.comments.first).must_equal comment
  end

  it 'HAPPY: proj manager should be able to create a new comment' do
    comment_data = DATA[:comments].first
    comment = TrackIt::CreateComment.call(
      account: @manager, project: @proj, comment_data:
    )

    _(@proj.comments.count).must_equal 1
    _(@proj.comments.first).must_equal comment
  end

  it 'HAPPY: admin should be able to create a new comment' do
    comment_data = DATA[:comments].first
    comment = TrackIt::CreateComment.call(
      account: @admin, project: @proj, comment_data:
    )

    _(@proj.comments.count).must_equal 1
    _(@proj.comments.first).must_equal comment
  end

  it 'SAD: not collaborator should not be able to create a new comment' do
    comment_data = DATA[:comments][3]
    _(proc {
      TrackIt::CreateComment.call(
        account: @not_collaborator,
        project: @proj,
        comment_data:
      )
    }).must_raise TrackIt::CreateComment::ForbiddenError
  end

  it 'SAD: not employee should not be able to create a new comment' do
    comment_data = DATA[:comments][3]
    _(proc {
      TrackIt::CreateComment.call(
        account: @not_employee,
        project: @proj,
        comment_data:
      )
    }).must_raise TrackIt::CreateComment::ForbiddenError
  end
end
