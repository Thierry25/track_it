# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Issue Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @owner_account_data = DATA[:accounts][0]
    @manager_account_data = DATA[:accounts][4]

    @wrong_account_data = DATA[:accounts][1]
    @account = TrackIt::Account.create(@owner_account_data)
    @org = @account.add_owned_organization(DATA[:organizations][0])
    @account.add_owned_organization(DATA[:organizations][1])
    TrackIt::Account.create(@wrong_account_data)
    @manager = TrackIt::Account.create(@manager_account_data)

    @dep = @org.add_department(DATA[:departments][0])
    @proj = @dep.add_project(DATA[:projects][0])
    @proj.add_manager(@manager)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting issues' do
    it 'HAPPY: should be able to get details for a single issue' do
      issue_data = DATA[:issues][1]
      issue = @account.add_submitted_issue(issue_data).save
      @proj.add_issue(issue)

      header 'AUTHORIZATION', auth_header(@owner_account_data)

      get "api/v1/issues/#{issue.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal issue.id
      _(result['attributes']['type']).must_equal issue_data['type']
      _(result['attributes']['priority']).must_equal issue_data['priority']
      _(result['attributes']['status']).must_equal issue_data['status']
      _(result['attributes']['description']).must_equal issue_data['description']
      _(result['attributes']['title']).must_equal issue_data['title']
      _(result['attributes']['completed']).must_equal issue_data['completed']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      issue_data = DATA[:issues][1]
      issue = @account.add_submitted_issue(issue_data).save
      @proj.add_issue(issue)

      get "api/v1/issues/#{issue.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      issue_data = DATA[:issues][1]
      issue = @account.add_submitted_issue(issue_data).save
      @proj.add_issue(issue)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)

      get "api/v1/issues/#{issue.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if issue does not exist' do
      header 'AUTHORIZATION', auth_header(@owner_account_data)
      get '/api/v1/issues/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating issues' do
    before do
      @issue_data = DATA[:issues][1]
    end

    # Manager can submit issues, organization_owner cannot
    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@manager_account_data)

      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues",
           @issue_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      comment = TrackIt::Issue.first

      _(created['id']).must_equal comment.id
      _(created['type']).must_equal comment.type
      _(created['priority']).must_equal comment.priority
      _(created['status']).must_equal comment.status
      _(created['description']).must_equal comment.description
      _(created['title']).must_equal comment.title
      _(created['completed']).must_equal comment.completed
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@owner_account_data)

      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues",
           @issue_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues",
           @issue_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @issue_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@manager_account_data)
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues",
           bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
