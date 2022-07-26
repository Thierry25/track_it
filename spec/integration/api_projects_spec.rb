# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:organizations].each do |organization_data|
      TrackIt::Organization.create(organization_data)
    end
  end

  describe 'Getting projects' do
    it 'HAPPY: should be able to get list of all projects' do
      org = TrackIt::Organization.first
      DATA[:departments].each do |department|
        org.add_department(department)
      end

      dep = TrackIt::Department.first
      DATA[:projects].each do |project|
        dep.add_project(project)
      end

      get "api/v1/organizations/#{org.id}/departments/#{dep.id}/projects"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 3
    end

    it 'HAPPY: should be able to get details of a single project' do
      org = TrackIt::Organization.first
      existing_proj = DATA[:projects][1]
      DATA[:departments].each do |department|
        org.add_department(department)
      end
      dep = TrackIt::Department.first
      proj = dep.add_project(existing_proj)

      get "api/v1/organizations/#{org.id}/departments/#{dep.id}/projects/#{proj.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal proj.id
      _(result['data']['attributes']['name']).must_equal existing_proj['name']
      _(result['data']['attributes']['description']).must_equal existing_proj['description']
      _(result['data']['attributes']['url']).must_equal existing_proj['url']
    end

    it 'SAD: should return error if unknown project requested' do
      org = TrackIt::Organization.first
      DATA[:departments].each do |department|
        org.add_department(department)
      end
      dep = TrackIt::Department.first
      get "/api/v1/organizations/#{org.id}/departments/#{dep.id}/projects/foobar"

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      org = TrackIt::Organization.first
      DATA[:departments].each do |department|
        org.add_department(department)
      end
      dep = TrackIt::Department.first
      dep.add_project(name: 'New Project', description: SecureDB.encrypt('Skrr'),
                      url: SecureDB.encrypt('https://www.github.com/Thierry25/TrackIt'))

      dep.add_project(name: 'Newest Project', description: SecureDB.encrypt('LOOL, HAHA'),
                      url: SecureDB.encrypt('https://www.github.com/Thierry25/EtaShare'))

      get "api/v1/organizations/#{org.id}/departments/#{dep.id}/projects/2%20or%20id%3E0"

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe "Creating New Projects within organization's department" do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @proj_data = DATA[:projects][1]
    end

    it 'HAPPY: should be able to create new projects' do
      org = TrackIt::Organization.first
      DATA[:departments].each do |department|
        org.add_department(department)
      end
      dep = TrackIt::Department.first

      post "api/v1/organizations/#{org.id}/departments/#{dep.id}/projects", @proj_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      proj = TrackIt::Project.first

      _(created['id']).must_equal proj.id
      _(created['name']).must_equal @proj_data['name']
      _(created['description']).must_equal @proj_data['description']
      _(created['url']).must_equal @proj_data['url']
    end

    it 'SECURITY: should not create project with mass assignment' do
      org = TrackIt::Organization.first
      DATA[:departments].each do |department|
        org.add_department(department)
      end
      dep = TrackIt::Department.first

      bad_data = @proj_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/organizations/#{org.id}/departments/#{dep.id}/projects", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
