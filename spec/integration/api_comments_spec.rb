# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Comment Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]

    @wrong_account_data = DATA[:accounts][1]
    @account = TrackIt::Account.create(@account_data)
    @org = @account.add_owned_organization(DATA[:organizations][0])
    @account.add_owned_organization(DATA[:organizations][1])
    TrackIt::Account.create(@wrong_account_data)

    @dep = @org.add_department(DATA[:departments][0])
    @proj = @dep.add_project(DATA[:projects][0])
    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting commments related to project' do
    it 'HAPPY: should be bale to get details for a single comment related to a project' do
      comment_data = DATA[:comments][1]
      comment = @account.add_submitted_comment(comment_data).save
      @proj.add_comment(comment)

      header 'AUTHORIZATION', auth_header(@account_data)

      get "api/v1/comments/#{comment.id}"

      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal comment.id
      _(result['attributes']['content']).must_equal comment_data['content']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      comment_data = DATA[:comments][1]
      comment = @account.add_submitted_comment(comment_data).save
      @proj.add_comment(comment)

      get "api/v1/comments/#{comment.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details wit wrong authorization' do
      comment_data = DATA[:comments][1]
      comment = @account.add_submitted_comment(comment_data).save
      @proj.add_comment(comment)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)

      get "api/v1/comments/#{comment.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if comment does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/comments/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Getting comments related to an issue' do
    before do
      @manager_account_data = DATA[:accounts][4]
      @manager = TrackIt::Account.create(@manager_account_data)

      @proj.add_manager(@manager)
      @issue = @manager.add_submitted_issue(DATA[:issues][0])
      @proj.add_issue(@issue)
    end

    it 'HAPPY: should be bale to get details for a single comment related to an issue' do
      comment_data = DATA[:comments][3]
      comment = @manager.add_submitted_comment(comment_data).save
      @issue.add_comment(comment)

      header 'AUTHORIZATION', auth_header(@manager_account_data)

      get "api/v1/comments/#{comment.id}"

      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal comment.id
      _(result['attributes']['content']).must_equal comment_data['content']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      comment_data = DATA[:comments][3]
      comment = @manager.add_submitted_comment(comment_data).save
      @issue.add_comment(comment)

      get "api/v1/comments/#{comment.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details wit wrong authorization' do
      comment_data = DATA[:comments][3]
      comment = @manager.add_submitted_comment(comment_data).save
      @issue.add_comment(comment)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)

      get "api/v1/comments/#{comment.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if comment does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/comments/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating projects comments' do
    before do
      @comment_data = DATA[:comments][2]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)

      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/comments", @comment_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      comment = TrackIt::Comment.first

      _(created['id']).must_equal comment.id
      _(created['content']).must_equal comment.content
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/comments", @comment_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/comments", @comment_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @comment_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/comments", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end

  describe 'Creating issues comments' do
    before do
      @comment_data_ = DATA[:comments][3]
      @manager_account_data = DATA[:accounts][4]
      @manager = TrackIt::Account.create(@manager_account_data)

      @proj.add_manager(@manager)
      @issue = @manager.add_submitted_issue(DATA[:issues][0])
      @proj.add_issue(@issue)
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@manager_account_data)

      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/comments",
           @comment_data_.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      comment = TrackIt::Comment.first

      _(created['id']).must_equal comment.id
      _(created['content']).must_equal comment.content
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/comments",
           @comment_data_.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/comments",
           @comment_data_.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @comment_data_.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@manager_account_data)
      post "api/v1/organizations/#{@org.id}/departments/#{@dep.id}/projects/#{@proj.id}/issues/#{@issue.id}/comments",
           bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
