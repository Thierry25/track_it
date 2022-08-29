# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Testing Department Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]

    @wrong_account_data = DATA[:accounts][1]
    @account = TrackIt::Account.create(@account_data)

    @org = @account.add_owned_organization(DATA[:organizations][1])
    TrackIt::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting departments information' do
    it 'HAPPY: Should be able to get details about a single department' do
      department_data = DATA[:departments][1]
      dep = @org.add_department(department_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "api/v1/organizations/#{@org.id}/departments/#{dep.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal dep.id
      _(result['data']['attributes']['name']).must_equal dep.name
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      department_data = DATA[:departments][1]
      dep = @org.add_department(department_data)

      get "api/v1/organizations/#{@org.id}/departments/#{dep.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body

      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      department_data = DATA[:departments][1]
      dep = @org.add_department(department_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "api/v1/organizations/#{@org.id}/departments/#{dep.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body

      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if unknown document requested' do
      header 'AUTHORIZATION', auth_header(@account_data)

      get "api/v1/organizations/#{@org.id}/departments/soccer"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Create departments' do
    before do
      @department_data = DATA[:departments][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)

      post "api/v1/organizations/#{@org.id}/departments", @department_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      department = TrackIt::Department.first

      _(created['id']).must_equal department.id
      _(created['name']).must_equal department.name
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/organizations/#{@org.id}/departments", @department_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/organizations/#{@org.id}/departments", @department_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @department_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/organizations/#{@org.id}/departments", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end

  # describe 'Create departments' do
  #   before do
  #     @org = TrackIt::Organization.first
  #     @department_data = DATA[:departments][1]
  #     @req_header = { 'CONTENT_TYPE' => 'application/json' }
  #   end

  #   it 'HAPPY: should be able to create new departments' do
  #     post "api/v1/organizations/#{@org.id}/departments", @department_data.to_json, @req_header

  #     _(last_response.status).must_equal 201
  #     _(last_response.header['Location'].size).must_be :>, 0

  #     created = JSON.parse(last_response.body)['data']['data']['attributes']
  #     department = TrackIt::Department.first

  #     _(created['id']).must_equal department.id
  #     _(created['name']).must_equal @department_data['name']
  #   end

  #   it 'SECURITY: should not create documents with assignment' do
  #     bad_data = @department_data.clone
  #     bad_data['created_at'] = '1990-12-01'

  #     post "api/v1/organizations/#{@org.id}/departments", bad_data.to_json, @req_header

  #     _(last_response.status).must_equal 400
  #     _(last_response.header['Location']).must_be_nil
  #   end
  # end
end
