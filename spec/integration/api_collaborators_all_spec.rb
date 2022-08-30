# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Add Collaborators all' do
  before do
    wipe_database

    DATA[:accounts].each do |account|
      TrackIt::Account.create(account)
    end

    @owner_data = DATA[:accounts][0]
    @proj_manager_data = DATA[:accounts][1]
    @available_manager_data = DATA[:accounts][2]
    @admin_data = DATA[:accounts][3]

    @owner = TrackIt::Account.first
    @proj_manager = TrackIt::Account.all[1]
    @available_manager = TrackIt::Account.all[2]
    @admin = TrackIt::Account.all[3]

    @org = @owner.add_owned_organization(DATA[:organizations][1])
    @dep = @org.add_department(DATA[:departments][1])
    @proj = @dep.add_project(DATA[:projects][1])

    # Add Admin
    TrackIt::AddAdmin.call(
      account: @owner, department_id: @dep.id, admin_email: @admin.email
    )

    # Add 2 project managers
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @proj_manager.email, role_id: 2
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: @available_manager.email, role_id: 2
    )

    # Add 7 soft devs and 3 testers
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[4].email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[5].email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[6].email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[7].email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[8].email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[9].email, role_id: 3
    )

    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[10].email, role_id: 3
    )
    # --
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[11].email, role_id: 4
    )
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.all[12].email, role_id: 4
    )
    TrackIt::AddEmployee.call(
      account: @owner, department_id: @dep.id, employee_email: TrackIt::Account.last.email, role_id: 4
    )

    @proj.add_manager(@proj_manager)
  end

  describe 'Adding all available employees as collaborators' do
    it 'HAPPY: owner should be able to add a list of employees as collobarators' do
      req_data = { department: @dep.id }

      header 'AUTHORIZATION', auth_header(@owner_data)

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/collaborators/all",
          req_data.to_json

      result = JSON.parse(last_response.body)['data']
      _(result.count).must_equal @dep.soft_devs.count + @dep.testers.count
      _(result.first['attributes']['email']).must_equal TrackIt::Account.all[4].email
      _(result.last['attributes']['email']).must_equal TrackIt::Account.last.email
    end

    it 'HAPPY: proj manager should be able to add a list of employees as collobarators' do
      req_data = { department: @dep.id }

      header 'AUTHORIZATION', auth_header(@proj_manager_data)

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/collaborators/all",
          req_data.to_json

      result = JSON.parse(last_response.body)['data']
      _(result.count).must_equal @dep.soft_devs.count + @dep.testers.count
      _(result.first['attributes']['email']).must_equal TrackIt::Account.all[4].email
      _(result.last['attributes']['email']).must_equal TrackIt::Account.last.email
    end

    it 'HAPPY: admin should be able to add a list of employees as collobarators' do
      req_data = { department: @dep.id }

      header 'AUTHORIZATION', auth_header(@owner_data)

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/collaborators/all",
          req_data.to_json

      result = JSON.parse(last_response.body)['data']
      _(result.count).must_equal @dep.soft_devs.count + @dep.testers.count
      _(result.first['attributes']['email']).must_equal TrackIt::Account.all[4].email
      _(result.last['attributes']['email']).must_equal TrackIt::Account.last.email
    end

    it 'SAD AUTHORIZATION: should not add collaborators without authorization' do
      req_data = { department: @dep.id }

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/collaborators/all",
          req_data.to_json

      result = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(result).must_be_nil
    end

    it 'BAD AUTHORIZATION: non-owner, non-admin or non-project manager should not be able to add a list of collabs' do
      req_data = { department: @dep.id }

      header 'AUTHORIZATION', auth_header(@available_manager_data)

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/collaborators/all",
          req_data.to_json

      result = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(result).must_be_nil
    end
  end
end
