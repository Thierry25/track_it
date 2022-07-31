# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Comment Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:organizations].each do |org_data|
      TrackIt::Organization.create(org_data)
    end
  end

  describe 'Getting commments related to project' do
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
      DATA[:comments].each do |comment|
        @proj.add_comment(comment)
      end
    end

    it 'HAPPY: should be able to get a list of all commments related to a project' do
      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/comments"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 10
    end

    it 'HAPPY: should be bale to get details for a single comment related to a project' do
      comment_data = DATA[:comments][1]
      comment = @proj.add_comment(comment_data).save

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/comments/#{comment.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['id']).must_equal comment.id
      _(result['content']).must_equal comment_data['content']
    end

    it 'SAD: should return error if unknown isuse requested' do
      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/comments/foobar"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Getting commments related to an issue' do
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
      DATA[:issues].each do |issue|
        @proj.add_issue(issue)
      end

      @issue = TrackIt::Issue.first
      DATA[:comments].each do |comment|
        @issue.add_comment(comment)
      end
    end

    it 'HAPPY: should be able to get a list of all commments related to an issue within a project' do
      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/comments"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 10
    end

    it 'HAPPY: should be bale to get details for a single comment related to an issue related to a project' do
      comment_data = DATA[:comments][1]
      comment = @issue.add_comment(comment_data).save

      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/comments/#{comment.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['id']).must_equal comment.id
      _(result['content']).must_equal comment_data['content']
    end

    it 'SAD: should return error if unknown isuse requested' do
      get "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}comments/foobar"

      _(last_response.status).must_equal 404
    end
  end

  # WILL TEST POSTING LATER!!
end
