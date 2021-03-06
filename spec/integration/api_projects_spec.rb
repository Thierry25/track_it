# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting projects' do
    it 'HAPPY: should be able to get list of all projects' do
      TrackIt::Project.create(DATA[:projects][0]).save
      TrackIt::Project.create(DATA[:projects][1]).save

      get 'api/v1/projects'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single project' do
      existing_proj = DATA[:projects][1]
      TrackIt::Project.create(existing_proj).save
      id = TrackIt::Project.first.id

      get "/api/v1/projects/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_proj['name']
    end

    it 'SAD: should return error if unknown project requested' do
      get '/api/v1/projects/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      TrackIt::Project.create(name: 'New Project', description: SecureDB.encrypt('Skrr'), type: 'Feature')
      TrackIt::Project.create(name: 'Newer Project', description: SecureDB.encrypt('Fun'), type: 'Bug')
      get 'api/v1/projects/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Projects' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @proj_data = DATA[:projects][1]
    end

    it 'HAPPY: should be able to create new projects' do
      post 'api/v1/projects', @proj_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      proj = TrackIt::Project.first

      _(created['id']).must_equal proj.id
      _(created['name']).must_equal @proj_data['name']
      _(created['description']).must_equal @proj_data['description']
      _(created['type']).must_equal @proj_data['type']
      _(created['organization']).must_equal @proj_data['organization']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @proj_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/projects', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
