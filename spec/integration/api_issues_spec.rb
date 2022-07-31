# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Issue Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:organizations].each do |org_data|
      TrackIt::Organization.create(org_data)
    end
  end

  describe 'Getting issues' do
    before do
      @org = TrackIt::Organization.first
      DATA[:departments].each do |department|
        @org.add_department(department)
      end

      @dep = TrackIt::Department.first
      DATA[:projects].each do |project|
        @dep.add_project(project)
      end

      @proj = TrackIt::Project.first
    end
    it 'HAPPY: should be able to get a list of all issues related to a project' do
      DATA[:issues].each do |issue|
        @proj.add_issue(issue)
      end

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 3
    end

    it 'HAPPY: should be able to get details of a single issue' do
      issue_data = DATA[:issues][1]
      issue = @proj.add_issue(issue_data).save

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{issue.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal issue.id
      _(result['data']['attributes']['type']).must_equal issue_data['type']
      _(result['data']['attributes']['priority']).must_equal issue_data['priority']
      _(result['data']['attributes']['status']).must_equal issue_data['status']
      _(result['data']['attributes']['description']).must_equal issue_data['description']
      _(result['data']['attributes']['title']).must_equal issue_data['title']
      _(result['data']['attributes']['completed']).must_equal issue_data['completed']
    end

    it 'SAD: should return error if unknown issue requested' do
      get "/api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/foobar"

      _(last_response.status).must_equal 404
    end
  end

  it 'HAPPY: should be able to create new issues' do
    org = TrackIt::Organization.first
    DATA[:departments].each do |department|
      org.add_department(department)
    end

    dep = TrackIt::Department.first
    DATA[:projects].each do |project|
      dep.add_project(project)
    end

    proj = TrackIt::Project.first
    issue_data = DATA[:issues][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/organizations/#{org.id}/departments/#{dep.id}/projects/#{proj.id}/issues",
         issue_data.to_json, req_header

    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    issue = TrackIt::Issue.first

    _(created['id']).must_equal issue.id
    _(created['ticket_number']).must_equal issue_data['ticket_number']
    _(created['type']).must_equal issue_data['type']
    _(created['priority']).must_equal issue_data['priority']
    _(created['status']).must_equal issue_data['status']
    _(created['description']).must_equal issue_data['description']
    _(created['title']).must_equal issue_data['title']
  end
end
