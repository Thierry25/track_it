# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Manager Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @another_account_data = DATA[:accounts][1]
    @wrong_account_data = DATA[:accounts][7]

    @account = TrackIt::Account.create(@account_data)
    @another_account = TrackIt::Account.create(@another_account_data)
    @wrong_account = TrackIt::Account.create(@wrong_account_data)

    @org = @account.add_owned_organization(DATA[:organizations][0])
    @dep = @org.add_department(DATA[:departments][1])
    @proj = @dep.add_project(DATA[:projects][1])

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Adding managers to a project' do
    it 'HAPPY: should add a valid manager' do
      TrackIt::Api.DB[:accounts_departments]
                  .insert(department_id: @dep.id, employee_id: @another_account.id, role_id: 2)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      added = JSON.parse(last_response.body)['data']['attributes']

      _(last_response.status).must_equal 200
      _(added['username']).must_equal @another_account.username
    end

    it 'SAD AUTHORIZATION: should not add a manager without authorization' do
      TrackIt::Api.DB[:accounts_departments]
                  .insert(department_id: @dep.id, employee_id: @another_account.id, role_id: 2)
      req_data = { email: @another_account.email }

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not add an account that is not part of the department' do
      req_data = { email: @another_account.email }

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not add an account does not have project manager role in department' do
      TrackIt::Api.DB[:accounts_departments]
                  .insert(department_id: @dep.id, employee_id: @another_account.id, role_id: 3)
      req_data = { email: @another_account.email }

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD_ AUTHORIZTION: should not add more than a project manager to a project' do
      # A project can only have one manager
      @proj.add_manager(@another_account)
      TrackIt::Api.DB[:accounts_departments]
                  .insert(department_id: @dep.id, employee_id: @wrong_account.id, role_id: 2)
      req_data = { email: @wrong_account.email }

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end
  end

  describe 'Removing managers from a project' do
    it 'HAPPY: should remove with proper authorization' do
      @proj.add_manager(@another_account)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      _(last_response.status).must_equal 200
    end

    it 'SAD AUTHORIZATION: should not remove without authorization' do
      @proj.add_manager(@another_account)
      req_data = { email: @another_account.email }
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'BAD AUTHORIZATION: should not remove with wrong authorization' do
      @proj.add_manager(@another_account)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/managers", req_data.to_json

      _(last_response.status).must_equal 403
    end
  end
end
