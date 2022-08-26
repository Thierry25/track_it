# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Employee Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @another_account_data = DATA[:accounts][1]
    @wrong_account_data = DATA[:accounts][2]

    @account = TrackIt::Account.create(@account_data)
    @another_account = TrackIt::Account.create(@another_account_data)
    @wrong_account = TrackIt::Account.create(@wrong_account_data)

    @org = @account.add_owned_organization(DATA[:organizations][1])

    @dep = @org.add_department(DATA[:departments][1])

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Adding employees to a department' do
    it 'HAPPY: should add a valid employee to department' do
      req_data = { email: @another_account.email, role: 3 }

      header 'AUTHORIZATION', auth_header(@account_data)

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      added = JSON.parse(last_response.body)['data']['attributes']

      _(last_response.status).must_equal 200
      _(added['username']).must_equal @another_account.username
    end

    it 'SAD AUTHORIZATION: should not add an employee without authorization' do
      req_data = { email: @another_account.email, role: 3 }

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not add an invalid employee' do
      req_data = { email: @account.email, role: 3 }

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not add with wrong authorization' do
      req_data = { email: @another_account.email, role: 3 }

      header 'AUTHOURIZATION', auth_header(@wrong_account_data)
      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end
  end

  describe 'Removing employees from a department' do
    it 'HAPPY: should remove with proper authorization' do
      @dep.add_employee(@another_account)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      _(last_response.status).must_equal 200
    end

    it 'SAD AUTHORIZATION: should not remove without authorization' do
      @dep.add_employee(@another_account)
      req_data = { email: @another_account.email }

      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      _(last_response.status).must_equal 403
    end

    it ' BAD AUTHORIZATION: should not remove invalid employee' do
      req_data = { email: @account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'BAD AUTHORIZATION: should not remove with wrong authorization' do
      @dep.add_employee(@another_account)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@another_account_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/employees", req_data.to_json

      _(last_response.status).must_equal 403
    end
  end
end
