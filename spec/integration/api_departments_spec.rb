# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Testing Department Handling' do
  before do
    wipe_database

    DATA[:organizations].each do |organization_data|
      TrackIt::Organization.create(organization_data)
    end
  end

  describe 'Getting departments information' do
    it 'HAPPY: Should be able to get a list of all departments within an organization' do
      org = TrackIt::Organization.first
      DATA[:departments].each do |dep|
        org.add_department(dep)
      end

      get "api/v1/organizations/#{org.id}/departments"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 4
    end

    it 'HAPPY: Should be able to get details about a single department' do
      department_data = DATA[:departments][1]
      org = TrackIt::Organization.first
      dep = org.add_department(department_data)

      get "api/v1/organizations/#{org.id}/departments/#{dep.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal dep.id
      _(result['data']['attributes']['name']).must_equal dep.name
    end

    it 'SAD: should return error if unknown document requested' do
      org = TrackIt::Organization.first

      get "api/v1/organizations/#{org.id}/departments/soccer"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Create departments' do
    before do
      @org = TrackIt::Organization.first
      @department_data = DATA[:departments][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new departments' do
      post "api/v1/organizations/#{@org.id}/departments", @department_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      department = TrackIt::Department.first

      _(created['id']).must_equal department.id
      _(created['name']).must_equal @department_data['name']
    end

    it 'SECURITY: should not create documents with assignment' do
      bad_data = @department_data.clone
      bad_data['created_at'] = '1990-12-01'

      post "api/v1/organizations/#{@org.id}/departments", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
