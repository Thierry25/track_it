# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assigned Issues Handling' do
  before do
    wipe_database

    @owner_data = DATA[:accounts][0]
    @manager_data = DATA[:accounts][2]
    @assignee_data = DATA[:accounts][3]

    @owner = TrackIt::Account.create(@owner_data)
    @manager = TrackIt::Account.create(@manager_data)
    @assignee = TrackIt::Account.create(@assignee_data)

    @org = @owner.add_owned_organization(DATA[:organizations][1])
    @dep = @org.add_department(DATA[:departments][2])
    @proj = @dep.add_project(DATA[:projects][1])

    @proj.add_manager(@manager)
    @proj.add_collaborator(@assignee)
    @issue = @manager.add_submitted_issue(DATA[:issues][1])
    @proj.add_issue(@issue)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Adding assignees to an issue' do
    it 'HAPPY: should add a valid assignee' do
      req_data = { email: @assignee.email }

      header 'AUTHORIZATION', auth_header(@manager_data)
      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
          req_data.to_json

      added = JSON.parse(last_response.body)['data']['attributes']

      _(last_response.status).must_equal 200
      _(added['username']).must_equal @assignee.username
    end

    it 'SAD AUTHORIZATION: should not add assignee without authorization' do
      req_data = { email: @assignee.email }

      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
          req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not an invalid assignee' do
      req_data = { email: @manager.email }

      header 'AUTHORIZATION', auth_header(@manager_data)
      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
          req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not an invalid assignee' do
      req_data = { email: @owner.email }

      header 'AUTHORIZATION', auth_header(@manager_data)
      put "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
          req_data.to_json

      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end
  end

  describe 'Removing assignees from an issue' do
    it 'HAPPY: should remove with proper authorization' do
      @issue.add_assignee(@assignee)
      req_data = { email: @assignee.email }

      header 'AUTHORIZATION', auth_header(@manager_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
             req_data.to_json

      _(last_response.status).must_equal 200
    end

    it 'SAD AUTHORIZATION: should remove with proper authorization' do
      @issue.add_assignee(@assignee)
      req_data = { email: @assignee.email }

      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
             req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'BAD AUTHORIZATION: should not remove invalid assignee' do
      req_data = { email: @assignee.email }

      header 'AUTHORIZATION', auth_header(@manager_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
             req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'BAD ASSIGNMENT: should not remove wrong authorization' do
      req_data = { email: @assignee.email }

      header 'AUTHORIZATION', auth_header(@owner_data)
      delete "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/assignments",
             req_data.to_json

      _(last_response.status).must_equal 403
    end
  end
end
