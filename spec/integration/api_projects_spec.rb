# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][1]

    @wrong_account_data = DATA[:accounts][2]
    @account = TrackIt::Account.create(@account_data)
    @org = @account.add_owned_organization(DATA[:organizations][1])
    TrackIt::Account.create(@wrong_account_data)

    @dep = @org.add_department(DATA[:departments][1])
    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting projects' do
    it 'HAPPY: should be able to get details of a single project' do
      project_data = DATA[:projects][1]
      proj = @dep.add_project(project_data)

      header 'AUTHORIZATION', auth_header(@account_data)

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{proj.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal proj.id
      _(result['attributes']['name']).must_equal project_data['name']
      _(result['attributes']['description']).must_equal project_data['description']
      _(result['attributes']['url']).must_equal project_data['url']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      project_data = DATA[:projects][1]
      proj = @dep.add_project(project_data)

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{proj.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse(last_response.body)
      _(result['data']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      project_data = DATA[:projects][1]
      proj = @dep.add_project(project_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{proj.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse(last_response.body)
      _(result['data']).must_be_nil
    end

    it 'SAD: should return error if project does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/fifa"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating projects' do
    before do
      @project_data = DATA[:projects][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)

      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects", @project_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      proj = TrackIt::Project.first

      _(created['id']).must_equal proj.id
      _(created['name']).must_equal proj.name
      _(created['description']).must_equal proj.description
      _(created['url']).must_equal proj.url
    end

    it 'SAD AUTHORIZATION: should not create without authorization' do
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects", @project_data.to_json

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil

      result = JSON.parse(last_response.body)

      _(result['data']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not create with wrong authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)

      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects", @project_data.to_json

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil

      result = JSON.parse(last_response.body)

      _(result['data']).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignments' do
      bad_data = @project_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
